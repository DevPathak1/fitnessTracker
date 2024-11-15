import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker/entity/exercise.dart';
import 'package:flutter/material.dart';

import 'package:fitness_tracker/entity/user.dart';
import 'package:fitness_tracker/entity/workout_session.dart';
import 'package:fitness_tracker/entity/routine.dart';

class UserProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  User? _user;
  User? get user => _user;
  String? get name => _user?.name;
  int? get age => _user?.age;
  double? get height => _user?.height;
  double? get weight => _user?.weight;
  DocumentReference<dynamic>? _userRef;
  DocumentReference<dynamic>? get userRef => _userRef;
  final _lastSessions = <WorkoutSession>[];
  List<WorkoutSession> get lastSessions => _lastSessions;
  List<WorkoutSession>? _allSessions;
  final _routines = <Routine>[];
  List<Routine> get routines => _routines;

  Future<int> create(
      String userId, String name, int age, double height, double weight) async {
    print('creating user: $name');
    _user = User(name, age, height, weight);
    _userRef = _db
        .collection('user')
        .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, options) => user.toFirestore())
        .doc(userId);
    var result = 0;
    await _userRef!.set(_user!).onError((e, _) {
      print("Error writing document: $e");
      result = -1;
    });
    if (result == 0) notifyListeners();
    return result;
  }

  Future<int> fetchUser(String userId) async {
    _userRef = _db
        .collection('user')
        .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, options) => user.toFirestore())
        .doc(userId);
    _user = (await _userRef!.get()).data();
    print('got user: ${_user?.toFirestore()}');
    if (_user == null) return -1;
    await _fetchLastSessions();
    return 0;
  }

  Future<int> _fetchLastSessions() async {
    if (_user == null) {
      return 1;
    }
    var result = 0;
    for (final id in _user!.lastWorkoutSessions) {
      final sessionRef = _db
          .collection('workout_session')
          .withConverter(
              fromFirestore: WorkoutSession.fromFirestore,
              toFirestore: (WorkoutSession session, options) =>
                  session.toFirestore())
          .doc(id);
      final data = (await sessionRef.get()).data();
      if (data != null) {
        _lastSessions.add(data);
      } else {
        result = -1;
        print('unable to fetch session id: $id');
      }
    }
    print('got sessions: $_lastSessions');
    notifyListeners();
    return result;
  }

  /// get all workout sessions
  Future<List<WorkoutSession>> getAllSessions() async {
    if (_allSessions != null) {
      return _allSessions!;
    }
    assert(_userRef != null, 'User is not initialized');

    final docs = (await _db
            .collection('workout_session')
            .withConverter(
                fromFirestore: WorkoutSession.fromFirestore,
                toFirestore: (WorkoutSession session, options) =>
                    session.toFirestore())
            .where('userId', isEqualTo: _userRef!.id)
            .get())
        .docs;
    return _allSessions = List.generate(docs.length, (i) => docs[i].data());
  }

  Future<List<Routine>> getRoutines() async {
    assert(_user != null, 'User is not initialized');
    if (_routines.length == _user!.routines.length) {
      return _routines;
    }
    for (final routineRef in _user!.routines) {
      final data = (await _db
              .collection('routine')
              .withConverter(
                  fromFirestore: Routine.fromFirestore,
                  toFirestore: (Routine routine, options) =>
                      routine.toFirestore())
              .doc(routineRef)
              .get())
          .data();
      if (data != null) {
        _routines.add(data);
      } else {
        print('cannot get routine');
        // TODO: remove unreached docs from user
      }
    }
    return _routines;
  }

  Future<WorkoutSession> addWorkoutSession(
      Timestamp start, Timestamp end, List<Exercise> exercises) async {
    assert(_userRef != null, 'User is not initialized');
    final session = WorkoutSession(_userRef!.id, start, end, exercises);
    _lastSessions.add(session);
    if (_allSessions != null) {
      _allSessions!.add(session);
    }
    final sessionRef = await _db
        .collection('workout_session')
        .withConverter(
            fromFirestore: WorkoutSession.fromFirestore,
            toFirestore: (WorkoutSession session, options) =>
                session.toFirestore())
        .add(session);
    if (_user!.lastWorkoutSessions.length == 10) {
      _user!.lastWorkoutSessions.removeAt(0);
      _user!.lastWorkoutSessions.add(sessionRef.id);
      await userRef!.update({
        'lastWorkoutSessions': _user!.lastWorkoutSessions,
      });
    } else {
      _user!.lastWorkoutSessions.add(sessionRef.id);
      await userRef!.update({
        'lastWorkoutSessions': FieldValue.arrayUnion([sessionRef.id]),
      });
    }
    return session;
  }
}

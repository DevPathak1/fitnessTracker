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
  String? get id => _userRef?.id;
  final _lastSessions = <WorkoutSession>[];
  List<WorkoutSession> get lastSessions => _lastSessions;
  List<WorkoutSession>? _allSessions;
  List<WorkoutSession>? get allSessions => _allSessions;
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
    if (result == 0) {
      notifyListeners();
      await _addSampleData(); // TODO: remove
    }
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
    notifyListeners();
    // TODO: for testing
    if (_lastSessions.isEmpty) {
      await _addSampleData();
    }
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
    _allSessions = List.generate(docs.length, (i) => docs[i].data());
    notifyListeners();
    return _allSessions!;
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
        print('unable to fetch routine id: $routineRef');
        // TODO: remove unreached docs from user
      }
    }
    notifyListeners();
    return _routines;
  }

  Future<WorkoutSession> addWorkoutSession(
      DateTime start, DateTime end, List<Exercise> exercises) async {
    assert(_userRef != null, 'User is not initialized');
    final startTime =
            Timestamp.fromMillisecondsSinceEpoch(start.millisecondsSinceEpoch),
        endTime =
            Timestamp.fromMillisecondsSinceEpoch(end.millisecondsSinceEpoch);
    final session = WorkoutSession(_userRef!.id, startTime, endTime, exercises);
    _lastSessions.add(session);
    if (_allSessions != null) {
      _allSessions!.add(session);
    }
    notifyListeners();
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
      await _userRef!.update({
        'lastWorkoutSessions': _user!.lastWorkoutSessions,
      });
    } else {
      _user!.lastWorkoutSessions.add(sessionRef.id);
      await _userRef!.update({
        'lastWorkoutSessions': FieldValue.arrayUnion([sessionRef.id]),
      });
    }
    return session;
  }

  Future<Routine> addRoutine(String name, List<Exercise> exercises) async {
    assert(_userRef != null, 'User is not initialized');
    final routine = Routine(_userRef!.id, name, exercises);
    _routines.add(routine);
    notifyListeners();
    final routineRef = await _db
        .collection('routine')
        .withConverter(
            fromFirestore: Routine.fromFirestore,
            toFirestore: (Routine routine, options) => routine.toFirestore())
        .add(routine);
    await _userRef!.update({
      'routines': FieldValue.arrayUnion([routineRef.id]),
    });
    return routine;
  }

  Future<void> _addSampleData() async {
    for (int i = 0; i < 15; i++) {
      final start = DateTime.now(), end = start.add(const Duration(minutes: 2));
      final exercises =
          List.generate(1, (_) => Exercise.init('push up', null, 1, 12, 50));
      await addWorkoutSession(start, end, exercises);
    }
    for (int i = 0; i < 5; i++) {
      final exercises =
          List.generate(1, (_) => Exercise.init('push up', null, 1, 12, 50));
      await addRoutine('routine $i', exercises);
    }
  }
}

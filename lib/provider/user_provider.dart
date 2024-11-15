import 'package:cloud_firestore/cloud_firestore.dart';
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
}

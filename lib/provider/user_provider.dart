import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fitness_tracker/entity/user.dart';
import 'package:fitness_tracker/entity/workout_session.dart';

class UserProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  User? _user;
  User? get user => _user;
  DocumentReference<dynamic>? _userRef;
  DocumentReference<dynamic>? get userRef => _userRef;
  final _lastSessions = <WorkoutSession>[];
  List<WorkoutSession> get lastSessions => _lastSessions;

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
    await fetchLastSessions();
    return 0;
  }

  Future<int> fetchLastSessions() async {
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
}

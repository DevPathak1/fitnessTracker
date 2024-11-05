import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitness_tracker/entity/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  User? _user;
  User? get user => _user;
  DocumentReference<dynamic>? _userRef;
  DocumentReference<dynamic>? get userRef => _userRef;

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
    // if (result == 0) notifyListeners();
    return result;
  }

  Future<int> get(String userId) async {
    _userRef = _db
        .collection('user')
        .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, options) => user.toFirestore())
        .doc(userId);
    _user = (await _userRef!.get()).data();
    print('got user: ${_user?.toFirestore()}');
    if (user == null) return -1;
    return 0;
  }
}

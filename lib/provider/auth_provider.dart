import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  FirebaseApp? _firebaseApp;
  bool get isInited => _firebaseApp != null;

  Future<void> init() async {
    _firebaseApp = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}

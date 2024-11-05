import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider, AuthProvider;

import 'provider/auth_provider.dart';
import 'widget/authentication.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Tracker',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: <Widget>[
          Consumer<AuthProvider>(
            builder: _authBuilder,
          ),
        ],
      ),
    );
  }

  AuthFunc _authBuilder(BuildContext context, AuthProvider appState, _) {
    print("logged in: ${appState.loggedIn}");
    if (!appState.loggedIn) context.push('/sign_in');
    return AuthFunc(
        loggedIn: appState.loggedIn,
        signOut: () {
          FirebaseAuth.instance.signOut();
        });
  }
}

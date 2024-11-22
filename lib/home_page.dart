import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider, AuthProvider, User;

import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'widget/authentication.dart';
import 'widget/wait_firebase_init.dart';
import 'entity/user.dart';
import 'entity/exercise.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    print("logged in: ${authProvider.loggedIn}");
    if (!authProvider.loggedIn && !_redirected) {
      _redirected = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.push('/sign_in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Tracker',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          AuthFunc(
              loggedIn: authProvider.loggedIn,
              signOut: () {
                FirebaseAuth.instance.signOut();
                _redirected = false;
              }),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              context.push('/view_saved_workouts');
            },
            child: const Text('View Saved Workouts'),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/workout_session');
            },
            child: const Text('Start a Workout Session'),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/view_workout_history');
            },
            child: const Text('View Workout History'),
          ),
        ],
      ),
    );
  }
}

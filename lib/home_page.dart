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
  bool _gotRoutine = false;

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

  /// TODO: testing widget to be remove in pord
  Widget _userInfoBuilder(BuildContext context, UserProvider userProvider, _) {
    if (userProvider.user == null) {
      return const Text('User is not initialized');
    }
    User user = userProvider.user!;
    final exercises =
        List.generate(1, (_) => Exercise.init('name', 'type', 1, 12, 50));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('User: ${user.toFirestore()}'),
        OutlinedButton(
          onPressed: () => userProvider.addWorkoutSession(
              Timestamp.now(), Timestamp.now(), exercises),
          child: const Text('add workout session'),
        ),
        Text('Workout sessions: ${userProvider.lastSessions}'),
        Row(
          children: [
            Visibility(
              visible: _gotRoutine,
              child: OutlinedButton(
                onPressed: () => userProvider.addRoutine('name', exercises),
                child: const Text('add routine'),
              ),
            ),
            Visibility(
              visible: !_gotRoutine,
              child: OutlinedButton(
                onPressed: () {
                  userProvider.getRoutines();
                  _gotRoutine = true;
                },
                child: const Text('get routine'),
              ),
            ),
          ],
        ),
        Text('Routines: ${userProvider.routines}'),
      ],
    );
  }
}

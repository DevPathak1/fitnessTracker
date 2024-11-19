import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'view_saved_workouts.dart'; // Add your new pages here
import 'workout_session.dart';
import 'view_workout_history.dart';
import 'provider/user_provider.dart';
import 'widget/wait_firebase_init.dart';

void _handleAuthStateChange(BuildContext context, AuthState state) {
  final user = switch (state) {
    SignedIn state => state.user,
    UserCreated state => state.credential.user,
    _ => null
  };
  if (user == null) {
    return;
  }

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  if (state is UserCreated) {
    String username = user.email!.split('@')[0];
    user.updateDisplayName(username);
    userProvider.create(
        user.uid, username, 18, 180, 70); // TODO: let user input its data
  } else {
    // existing user
    userProvider.fetchUser(user.uid);
  }

  if (!user.emailVerified) {
    // user.sendEmailVerification(); // TODO: uncomment this in production
    const snackBar = SnackBar(
        content: Text('Please check your email to verify your email address'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  context.pop(); // the login page should always be pushed
  context.pushReplacement('/');
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'sign_in',
          builder: (context, state) {
            return WaitFirebaseInit(
              child: SignInScreen(
                actions: [
                  ForgotPasswordAction(((context, email) {
                    final uri = Uri(
                      path: '/sign_in/forgot_password',
                      queryParameters: <String, String?>{
                        'email': email,
                      },
                    );
                    context.push(uri.toString());
                  })),
                  AuthStateChangeAction(_handleAuthStateChange),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'forgot_password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
        // Registering all routes, ensuring no paths are commented out
        GoRoute(
          path: 'view_saved_workouts',
          builder: (context, state) => const ViewSavedWorkoutsPage(),
        ),
        GoRoute(
          path: 'workout_session',
          builder: (context, state) => const WorkoutSessionPage(),
        ),
        // GoRoute(
        //   path: 'view_workout_history',
        //   builder: (context, state) => const ViewWorkoutHistoryPage(),
        // ),
        // GoRoute(
        //   path: 'track_each_exercise',
        //   builder: (context, state) => const TrackEachExercisePage(),
      ],
    ),
  ],
);

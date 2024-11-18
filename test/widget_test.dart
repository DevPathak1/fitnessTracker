// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker/main.dart';
import 'package:fitness_tracker/firebase_options.dart';
import 'package:fitness_tracker/provider/user_provider.dart';

void main() {
  testWidgets('main test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const App());
    print('starting test');
    await testdb();
  });
}

Future<void> testdb() async {
  const userId = 'wpooKB2P7GSitzppjjw8P75iv4v1';
  print('starting testdb');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('inited firebase');
  final userProvider = UserProvider();
  await userProvider.fetchUser(userId);
  print('got user');
  expect(userProvider.id, userId);
  print(userProvider.user?.toFirestore().toString());
}

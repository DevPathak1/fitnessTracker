import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker/provider/auth_provider.dart';

class WaitFirebaseInit extends StatelessWidget {
  final Widget child;

  const WaitFirebaseInit({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isInited) {
      return child;
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

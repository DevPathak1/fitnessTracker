import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitness_tracker/provider/user_provider.dart';
import 'package:fitness_tracker/entity/workout_session.dart';

class ViewSavedWorkoutsPage extends StatelessWidget {
  const ViewSavedWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Saved Workouts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(builder: _workoutsContentBuilder),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _workoutsContentBuilder(
      BuildContext context, UserProvider userProvider, _) {
    final List<WorkoutSession> workouts;
    if (userProvider.allSessions == null) {
      // userProvider.getAllSessions();
      workouts = userProvider.lastSessions;
    } else {
      workouts = userProvider.allSessions!;
    }

    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final duration = Duration(
            seconds: workout.endTime.seconds - workout.startTime.seconds);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(workout.startTime.toDate().toString()),
            subtitle: Text(
                '${(duration.inHours == 0 ? '' : '${duration.inHours}h')} ${duration.inMinutes}m'),
            trailing: Text(
              "${workout.exercises.length} Exercises",
            ),
            onTap: () {
              // Handle navigation to workout details page if needed
            },
          ),
        );
      },
    );
  }
}

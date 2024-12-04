import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker/provider/user_provider.dart';
import 'package:fitness_tracker/entity/workout_session.dart';
import 'package:go_router/go_router.dart';

class ViewWorkoutHistoryPage extends StatelessWidget {
  const ViewWorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.lastSessions.isEmpty) {
            return const Center(
              child: Text(
                'No workout history available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: userProvider.lastSessions.length,
            itemBuilder: (context, index) {
              final workoutSession = userProvider.lastSessions[index];
              final duration = Duration(
                  seconds: workoutSession.endTime.seconds -
                      workoutSession.startTime.seconds);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    workoutSession.startTime.toDate().toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    '${(duration.inHours == 0 ? '' : '${duration.inHours}h ')}${duration.inMinutes}m',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    "${workoutSession.exercises.length} Exercises",
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    _showRoutinePopup(context, workoutSession);
                  },
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  void _showRoutinePopup(BuildContext context, WorkoutSession workoutSession) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Workout on ${workoutSession.startTime.toDate()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Exercises:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...workoutSession.exercises.map((exercise) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        exercise.name,
                        style: const TextStyle(color: Colors.black),
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);

                // Add the workout session
                final newWorkoutSession = await userProvider.addWorkoutSession(
                  DateTime.now(),
                  DateTime.now().add(const Duration(hours: 1)), // Default duration
                  workoutSession.exercises,
                );
                Navigator.pop(context); // Close the popup

                // Navigate to the workout session page with GoRouter
                GoRouter.of(context).push(
                  '/workout_session',
                  extra: {
                    'session': newWorkoutSession,
                    'initialExercises': workoutSession.exercises,
                  },
                );
                print("Navigating to workout session with exercises: ${workoutSession.exercises.map((e) => e.name).toList()}");
              },
              child: const Text('Start Workout'),
            ),
          ],
        );
      },
    );
  }
}

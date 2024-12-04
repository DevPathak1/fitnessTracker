import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker/provider/user_provider.dart';
import 'package:fitness_tracker/entity/routine.dart';
import 'package:fitness_tracker/entity/exercise.dart';
import 'package:go_router/go_router.dart';

class ViewSavedWorkoutsPage extends StatefulWidget {
  const ViewSavedWorkoutsPage({super.key});

  @override
  State<ViewSavedWorkoutsPage> createState() => _ViewSavedWorkoutsPage();
}

class _ViewSavedWorkoutsPage extends State<ViewSavedWorkoutsPage> {
  bool _gotRoutines = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Saved Routines',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (!_gotRoutines) {
            userProvider.getRoutines();
            _gotRoutines = true;
          }
          final routines = userProvider.routines;
          if (routines.isEmpty) {
            return const Center(
              child: Text(
                'No routines available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    routine.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    '${routine.exercises.length} Exercises',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    _showRoutinePopup(context, routine, index);
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

  void _showRoutinePopup(BuildContext context, Routine routine, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(routine.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Exercises:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...routine.exercises
                  .map((exercise) => Text(exercise.name))
                  .toList(),
            ],
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
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);

                try {
                  // Fetch the full routine details from Firestore
                  final routineSnapshot = await FirebaseFirestore.instance
                      .collection('routine')
                      .doc(routine.id)
                      .get();

                  if (routineSnapshot.exists) {
                    final routineData = routineSnapshot.data()!;
                    final List<dynamic> exercisesData =
                        routineData['exercises'];
                    final exercises = exercisesData.map((e) {
                      return Exercise.fromMap(e['name'], e['type'], e['sets']);
                    }).toList();

                    // Add the workout session
                    final workoutSession = await userProvider.addWorkoutSession(
                      DateTime.now(),
                      DateTime.now()
                          .add(const Duration(hours: 1)), // Default duration
                      exercises,
                    );
                    Navigator.pop(context); // Close the popup

                    // Navigate to the workout session page with GoRouter
                    GoRouter.of(context).push(
                      '/workout_session',
                      extra: {
                        'session': workoutSession,
                        'initialExercises': exercises,
                      },
                    );
                    print(
                        "Navigating to workout session with exercises: ${exercises.map((e) => e.name).toList()}");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to load routine details.')),
                    );
                  }
                } catch (e) {
                  print('Error fetching routine: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'An error occurred while loading the routine.')),
                  );
                }
              },
              child: const Text('Start Workout'),
            ),
            TextButton(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await userProvider.deleteRoutine(routine, index);
                Navigator.pop(context); // Close the popup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Routine deleted successfully!')),
                );
              },
              child: const Text(
                'Delete Routine',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

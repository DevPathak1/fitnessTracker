import 'dart:convert';
import 'package:fitness_tracker/rapidapikey.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'entity/exercise.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker/provider/user_provider.dart';
import 'package:go_router/go_router.dart';

class WorkoutSessionPage extends StatefulWidget {
  final List<Exercise>? initialExercises;

  const WorkoutSessionPage({super.key, this.initialExercises});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    exercises = widget.initialExercises ?? [];
    print("Loaded exercises: ${exercises.map((e) => e.name).toList()}");
  }

  Future<List<String>> _fetchAllExercises() async {
    List<String> allExercises = [];
    int offset = 0;
    int limit = 1300;

    try {
      while (true) {
        final response = await http.get(
          Uri.parse(
              'https://exercisedb.p.rapidapi.com/exercises?limit=$limit&offset=$offset'),
          headers: {
            'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
            'X-RapidAPI-Key': apikey,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          if (data.isEmpty) break;

          allExercises.addAll(
              data.map<String>((exercise) => exercise['name'] as String).toList());

          offset += limit;
        } else {
          throw Exception('Failed to load exercises');
        }
      }
    } catch (error) {
      print('Error fetching exercises: $error');
    }

    return allExercises;
  }

  void _showExerciseDetailsDialog(Exercise exercise) {
  // Create a copy of the sets list to avoid modifying the original until the user is done
  List<ExerciseSet> sets = List.from(exercise.sets);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Track ${exercise.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Sets:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Using Column with map instead of ListView.builder to avoid viewport issues
                Column(
                  children: sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: set.weight.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                                labelStyle: TextStyle(color: Colors.pink),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  set.weight = double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: set.reps.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                labelStyle: TextStyle(color: Colors.pink),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  set.reps = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                sets.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Add a new set with default values
                      sets.add(ExerciseSet(10, 0.0));
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text('Add Set'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update the original exercise's sets with the new values
                  exercise.sets.clear();
                  exercise.sets.addAll(sets);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Done'),
            ),
          ],
        );
      });
    },
  );
}


  void _showAddExerciseDialog() {
    String? selectedExercise;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Add Exercise',
            style: TextStyle(color: Colors.white),
          ),
          content: FutureBuilder<List<String>>(
            future: _fetchAllExercises(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text(
                  'Failed to load exercises. Please try again.',
                  style: TextStyle(color: Colors.white),
                );
              }

              final exercisesList = snapshot.data!;

              return DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(
                    backgroundColor: Colors.grey[800],
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return Container(
                      color: isSelected ? Colors.pink : Colors.transparent,
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
                items: exercisesList,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: 'Select an exercise',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                ),
                onChanged: (value) {
                  selectedExercise = value;
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedExercise != null && selectedExercise!.isNotEmpty) {
                  setState(() {
                    exercises.add(
                      Exercise.init(selectedExercise!, null, 1, 10, 0),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNameDialog(BuildContext context, Function(String) onSave) {
  String routineName = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Save Workout Routine'),
        content: TextField(
          onChanged: (value) {
            routineName = value;
          },
          decoration: const InputDecoration(
            hintText: 'Enter routine name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (routineName.isNotEmpty) {
                onSave(routineName);
                Navigator.pop(context);
              } else {
                // Show a warning to provide a name
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a routine name.'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _saveWorkoutSession() async {
  if (exercises.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No exercises to save. Add exercises first.'),
      ),
    );
    return;
  }

  _showNameDialog(context, (routineName) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.addRoutine(routineName, exercises);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Routine "$routineName" saved successfully.')),
      );

      setState(() {
        exercises.clear();
      });
    } catch (error) {
      print('Error saving routine: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save routine. Please try again.'),
        ),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout Session',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final setsSummary = exercise.sets
                    .map((set) => '${set.reps} reps at ${set.weight} lbs')
                    .join(', ');

                return ListTile(
                  title: Text(
                    exercise.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    setsSummary,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  leading: const Icon(Icons.fitness_center, color: Colors.pink),
                  tileColor: Colors.grey[800],
                  onTap: () {
                    _showExerciseDetailsDialog(exercise);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                heroTag: 'addExerciseButton',
                onPressed: _showAddExerciseDialog,
                label: const Text("Add Exercise"),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.pink,
              ),
              const SizedBox(width: 16),
              FloatingActionButton.extended(
                heroTag: 'saveWorkoutButton',
                onPressed: _saveWorkoutSession,
                label: const Text("Save Workout"),
                icon: const Icon(Icons.save),
                backgroundColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}

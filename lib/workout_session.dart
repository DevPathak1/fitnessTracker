import 'dart:convert';
import 'package:fitness_tracker/rapidapikey.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:go_router/go_router.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final List<String> exercises = []; // Stores exercises added by the user

  Future<List<String>> _fetchAllExercises() async {
    List<String> allExercises = [];
    int offset = 0;
    int limit = 1300; // Adjust based on API documentation

    try {
      while (true) {
        final response = await http.get(
          Uri.parse(
              'https://exercisedb.p.rapidapi.com/exercises?limit=$limit&offset=$offset'),
          headers: {
            'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
            'X-RapidAPI-Key': apikey, // Replace with your actual API key
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          // Break the loop if no more data is returned
          if (data.isEmpty) break;

          allExercises.addAll(
              data.map<String>((exercise) => exercise['name'] as String).toList());

          // Increment the offset for the next batch
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
            future: _fetchAllExercises(), // Fetch all exercises
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
                  showSearchBox: true, // Enables the search box
                  menuProps: MenuProps(
                    backgroundColor: Colors.grey[800],
                  ),
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(
                    maxHeight: 300, // Ensures the dropdown menu is scrollable
                  ),
                ),
                items: exercisesList,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: 'Select an exercise',
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                    focusedBorder: const UnderlineInputBorder(
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
                Navigator.pop(context); // Close the dialog
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
                    exercises.add(selectedExercise!); // Add the selected exercise
                  });
                }
                Navigator.pop(context); // Close the dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Session Name',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white), // Profile icon
            onPressed: () {
              context.push('/profile'); // Navigate to profile page
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    exercises[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: const Icon(Icons.fitness_center, color: Colors.pink),
                  tileColor: Colors.grey[800],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _showAddExerciseDialog,
            label: const Text("Add Exercise"),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.pink,
          ),
          const SizedBox(height: 16),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}

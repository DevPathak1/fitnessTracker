import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewSavedWorkoutsPage extends StatefulWidget {
  const ViewSavedWorkoutsPage({super.key});

  @override
  State<ViewSavedWorkoutsPage> createState() => _ViewSavedWorkoutsPageState();
}

class _ViewSavedWorkoutsPageState extends State<ViewSavedWorkoutsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Center(
        child: Text("User not logged in."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Saved Workouts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workouts') // Replace with your Firestore collection name
            .where('userId', isEqualTo: userId) // Filter workouts for the logged-in user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred while fetching workouts." , style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No saved workouts found.", style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),),
            );
          }

          final workouts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final workoutData = workout.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(workoutData['name'] ?? 'Unnamed Workout'),
                  subtitle: Text(workoutData['description'] ?? 'No description'),
                  trailing: Text(
                    "${workoutData['exercises']?.length ?? 0} Exercises",
                  ),
                  onTap: () {
                    // Handle navigation to workout details page if needed
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
}

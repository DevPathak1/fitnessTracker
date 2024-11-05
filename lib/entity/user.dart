import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final int age;
  final double height;
  final double weight;
  final List<DocumentReference<Map<String, dynamic>>>
      lastWorkoutSessions; // ref(WorkoutSession)
  final List<DocumentReference<Map<String, dynamic>>> routines; // ref(Routine)

  User(this.name, this.age, this.height, this.weight)
      : lastWorkoutSessions = <DocumentReference<Map<String, dynamic>>>[],
        routines = <DocumentReference<Map<String, dynamic>>>[];
  User._init(this.name, this.age, this.height, this.weight,
      this.lastWorkoutSessions, this.routines);

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return User._init(
        data?['name'],
        data?['age'],
        data?['height'],
        data?['weight'],
        List.from(data?['lastWorkoutSessions']),
        List.from(data?['routines']));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'lastWorkoutSessions': lastWorkoutSessions,
      'routines': routines
    };
  }
}

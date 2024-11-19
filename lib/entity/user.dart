import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

/// User document stored in Firestore
class User {
  final String name;
  final int age;
  final double height;
  final double weight;

  /// ref(WorkoutSession) [old..new].length <= 10
  final List<String> lastWorkoutSessions;

  /// ref(Routine)
  final List<String> routines;
  final List<Exercise> savedExercises;

  User(this.name, this.age, this.height, this.weight)
      : lastWorkoutSessions = <String>[],
        routines = <String>[],
        savedExercises = <Exercise>[];
  User._init(this.name, this.age, this.height, this.weight,
      this.lastWorkoutSessions, this.routines, this.savedExercises);

  factory User.fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> snapshot,
  SnapshotOptions? options,
) {
  final data = snapshot.data()!;
  return User._init(
    data['name'],
    data['age'],
    (data['height'] is int ? data['height'].toDouble() : data['height']) ?? 0.0,
    (data['weight'] is int ? data['weight'].toDouble() : data['weight']) ?? 0.0,
    List.from(data['lastWorkoutSessions']),
    List.from(data['routines']),
    List.generate(
      data['savedExercises'].length,
      (i) => Exercise.fromMap(
        data['savedExercises'][i]['name'],
        data['savedExercises'][i]['type'],
        data['savedExercises'][i]['sets'],
      ),
    ),
  );
}


  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'lastWorkoutSessions': lastWorkoutSessions,
      'routines': routines,
      'savedExercises': List.generate(
          savedExercises.length, (i) => savedExercises[i].toFirestore()),
    };
  }
}

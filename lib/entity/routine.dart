import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class Routine {
  final String userId; // ref(User)
  final String name;
  final List<Exercise> exercises;

  Routine(this.userId, this.name, this.exercises);

  factory Routine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Routine(
        data['userId'],
        data['name'],
        List.generate(
            data['exercises'].length,
            (i) => Exercise.fromMap(data['exercises'][i]['name'],
                data['exercises'][i]['type'], data['exercises'][i]['sets'])));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'exercises':
          List.generate(exercises.length, (i) => exercises[i].toFirestore())
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class Routine {
  final DocumentReference<Map<String, dynamic>> userId;
  final String name;
  final List<Exercise> exercises;

  Routine(this.userId, this.name, this.exercises);

  factory Routine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Routine(
        data?['userId'], data?['name'], List.from(data?['exercises']));
  }

  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'name': name, 'exercises': exercises};
  }
}

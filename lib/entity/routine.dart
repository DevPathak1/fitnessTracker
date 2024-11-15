import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';
import 'exercise.dart';

class Routine extends Session {
  final String name;

  Routine(String userId, this.name, List<Exercise> exercises)
      : super(userId, exercises);
  Routine.fromMap(
      String userId, this.name, List<Map<String, dynamic>> exercises)
      : super.fromMap(userId, exercises);

  factory Routine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Routine.fromMap(data['userId'], data['name'], data['exercises']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'exercises': exerciseList,
    };
  }
}

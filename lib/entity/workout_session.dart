import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class WorkoutSession {
  final DocumentReference<Map<String, dynamic>> userId;
  final Timestamp startTime;
  final Timestamp endTime;
  final List<Exercise> exercises;

  WorkoutSession(this.userId, this.startTime, this.endTime, this.exercises);

  factory WorkoutSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return WorkoutSession(data?['userId'], data?['startTime'], data?['endTime'],
        List.from(data?['exercises']));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'exercises': exercises
    };
  }
}

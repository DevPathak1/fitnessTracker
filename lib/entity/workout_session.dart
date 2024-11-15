import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';
import 'exercise.dart';

class WorkoutSession extends Session {
  final Timestamp startTime;
  final Timestamp endTime;

  WorkoutSession(
      String userId, this.startTime, this.endTime, List<Exercise> exercises)
      : super(userId, exercises);
  WorkoutSession.fromMap(String userId, this.startTime, this.endTime,
      List<Map<String, dynamic>> exercises)
      : super.fromMap(userId, exercises);

  factory WorkoutSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return WorkoutSession.fromMap(
        data['userId'], data['startTime'], data['endTime'], data['exercises']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'exercises': exerciseList,
    };
  }
}

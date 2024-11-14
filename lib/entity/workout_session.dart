import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';

class WorkoutSession extends Session {
  final Timestamp startTime;
  final Timestamp endTime;

  WorkoutSession(String userId, this.startTime, this.endTime,
      List<Map<String, dynamic>> exercises)
      : super(userId, exercises);

  factory WorkoutSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return WorkoutSession(
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

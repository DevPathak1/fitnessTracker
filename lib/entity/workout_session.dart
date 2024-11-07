import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class WorkoutSession {
  final String userId; // ref(User)
  final Timestamp startTime;
  final Timestamp endTime;
  final List<Exercise> exercises;

  WorkoutSession(this.userId, this.startTime, this.endTime, this.exercises);

  factory WorkoutSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return WorkoutSession(
        data['userId'],
        data['startTime'],
        data['endTime'],
        List.generate(
            data['exercises'].length,
            (i) => Exercise.fromMap(data['exercises'][i]['name'],
                data['exercises'][i]['type'], data['exercises'][i]['sets'])));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'exercises':
          List.generate(exercises.length, (i) => exercises[i].toFirestore())
    };
  }
}

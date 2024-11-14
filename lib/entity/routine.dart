import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';

class Routine extends Session {
  final String name;

  Routine(String userId, this.name, List<Map<String, dynamic>> exercises)
      : super(userId, exercises);

  factory Routine.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Routine(data['userId'], data['name'], data['exercises']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'exercises': exerciseList,
    };
  }
}

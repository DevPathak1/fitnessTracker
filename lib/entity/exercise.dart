import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String name;
  final String? type;
  final List<ExerciseSet> sets;

  Exercise(this.name, this.type, this.sets);
  Exercise.init(this.name, this.type, int nSets, int reps, double weight)
      : sets = List.generate(nSets, (_) => ExerciseSet(reps, weight));

  factory Exercise.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Exercise(
        data?['name'],
        data?['type'],
        List.generate(data?['sets'].length ?? 0,
            (i) => ExerciseSet(data!['sets'][i].reps, data['sets'][i].weight)));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (type != null) 'type': type,
      'sets': sets,
    };
  }
}

class ExerciseSet {
  final int reps;
  final double weight;

  ExerciseSet(this.reps, this.weight);
}

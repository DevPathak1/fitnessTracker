import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String name;
  final String? type;
  final List<ExerciseSet> sets;

  Exercise(this.name, this.type, this.sets);
  Exercise.init(this.name, this.type, int nSets, int reps, double weight)
      : sets = List.generate(nSets, (_) => ExerciseSet(reps, weight));
  Exercise.fromMap(this.name, this.type, List<dynamic> setMaps)
      : sets = List.generate(setMaps.length,
            (i) => ExerciseSet(setMaps[i]['reps'], setMaps[i]['weight']));

  factory Exercise.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Exercise.fromMap(data['name'], data['type'], data['sets']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (type != null) 'type': type,
      'sets': List.generate(sets.length, (i) => sets[i].toMap()),
    };
  }
}

class ExerciseSet {
  final int reps;
  final double weight;

  ExerciseSet(this.reps, this.weight);

  Map<String, dynamic> toMap() {
    return {'reps': reps, 'weight': weight};
  }
}

import 'exercise.dart';

abstract class Session {
  final String _userId;

  /// ref(User)
  String get userId => _userId;
  final List<Exercise> exercises;
  List<Map<String, dynamic>> get exerciseList =>
      List.generate(exercises.length, (i) => exercises[i].toFirestore());

  Session(this._userId, this.exercises);
  Session.fromMap(this._userId, List<Map<String, dynamic>> exerciseMapList)
      : exercises = List.generate(
            exerciseMapList.length,
            (i) => Exercise.fromMap(exerciseMapList[i]['name'],
                exerciseMapList[i]['type'], exerciseMapList[i]['sets']));
}

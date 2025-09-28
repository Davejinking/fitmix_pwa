import 'package:hive/hive.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 3)
class ExerciseSet extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  ExerciseSet({this.weight = 0.0, this.reps = 0});

  ExerciseSet copyWith({
    double? weight,
    int? reps,
  }) {
    return ExerciseSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  @override
  String toString() => 'Set(weight: $weight, reps: $reps)';
}
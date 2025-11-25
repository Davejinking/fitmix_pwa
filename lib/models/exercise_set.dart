import 'package:hive/hive.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 3)
class ExerciseSet extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  @HiveField(2)
  bool isCompleted;

  ExerciseSet({
    this.weight = 0.0,
    this.reps = 0,
    this.isCompleted = false,
  });

  ExerciseSet copyWith({
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() => 'Set(weight: $weight, reps: $reps, completed: $isCompleted)';
}
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import 'exercise_set.dart';
part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String bodyPart; // 가슴/등/어깨/팔/하체/복근/유산소

  @HiveField(2)
  List<ExerciseSet> sets;

  @HiveField(3)
  int eccentricSeconds; // Lowering duration (e.g., 4s)

  @HiveField(4)
  int concentricSeconds; // Lifting duration (e.g., 2s)

  @HiveField(5)
  bool isTempoEnabled; // Toggle for tempo mode

  @HiveField(6)
  int targetSets; // 🔥 Target sets for routine planning (e.g., 3)

  @HiveField(7)
  String targetReps; // 🔥 Target reps for routine planning (e.g., "8-12" or "5")

  @HiveField(8)
  String? memo; // 🔥 Session memo (e.g., "Shoulder hurts today", "Increased weight")

  Exercise({
    required this.name,
    required this.bodyPart,
    List<ExerciseSet>? sets,
    this.eccentricSeconds = 4,
    this.concentricSeconds = 2,
    this.isTempoEnabled = false,
    this.targetSets = 3, // Default: 3 sets
    this.targetReps = '10', // Default: 10 reps
    this.memo, // 🔥 Nullable memo field
  }) : sets = sets ?? [ExerciseSet()];

  /// Exercise 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Exercise copyWith({
    String? name,
    String? bodyPart,
    List<ExerciseSet>? sets,
    int? eccentricSeconds,
    int? concentricSeconds,
    bool? isTempoEnabled,
    int? targetSets,
    String? targetReps,
    String? memo,
  }) {
    return Exercise(
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
      eccentricSeconds: eccentricSeconds ?? this.eccentricSeconds,
      concentricSeconds: concentricSeconds ?? this.concentricSeconds,
      isTempoEnabled: isTempoEnabled ?? this.isTempoEnabled,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      memo: memo ?? this.memo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
           other.name == name &&
           other.bodyPart == bodyPart &&
           listEquals(other.sets, sets) &&
           other.targetSets == targetSets &&
           other.targetReps == targetReps;
  }

  @override
  int get hashCode => name.hashCode ^ bodyPart.hashCode ^ sets.hashCode ^ targetSets.hashCode ^ targetReps.hashCode;

  @override
  String toString() {
    return 'Exercise(name: $name, bodyPart: $bodyPart, sets: ${sets.length}, target: ${targetSets}x$targetReps)';
  }
}

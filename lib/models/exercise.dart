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

  Exercise({
    required this.name,
    required this.bodyPart,
    List<ExerciseSet>? sets,
    this.eccentricSeconds = 4,
    this.concentricSeconds = 2,
    this.isTempoEnabled = false,
  }) : sets = sets ?? [ExerciseSet()];

  /// Exercise 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Exercise copyWith({
    String? name,
    String? bodyPart,
    List<ExerciseSet>? sets,
    int? eccentricSeconds,
    int? concentricSeconds,
    bool? isTempoEnabled,
  }) {
    return Exercise(
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
      eccentricSeconds: eccentricSeconds ?? this.eccentricSeconds,
      concentricSeconds: concentricSeconds ?? this.concentricSeconds,
      isTempoEnabled: isTempoEnabled ?? this.isTempoEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
           other.name == name &&
           other.bodyPart == bodyPart &&
           listEquals(other.sets, sets);
  }

  @override
  int get hashCode => name.hashCode ^ bodyPart.hashCode ^ sets.hashCode;

  @override
  String toString() {
    return 'Exercise(name: $name, bodyPart: $bodyPart, sets: ${sets.length})';
  }
}

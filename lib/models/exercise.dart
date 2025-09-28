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

  Exercise({
    required this.name,
    required this.bodyPart,
    List<ExerciseSet>? sets,
  }) : sets = sets ?? [ExerciseSet()];

  /// Exercise 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Exercise copyWith({
    String? name,
    String? bodyPart,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
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

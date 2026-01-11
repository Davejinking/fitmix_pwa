import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'exercise.dart';

part 'routine.g.dart';

/// 저장된 루틴 모델
@HiveType(typeId: 4)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // e.g., "PUSH DAY A", "가슴 A"

  @HiveField(2)
  List<Exercise> exercises;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? lastUsedAt;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
    DateTime? createdAt,
    this.lastUsedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Routine 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Routine copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Routine &&
           other.id == id &&
           other.name == name &&
           listEquals(other.exercises, exercises);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ exercises.hashCode;

  @override
  String toString() {
    return 'Routine(id: $id, name: $name, exercises: ${exercises.length}개)';
  }
}

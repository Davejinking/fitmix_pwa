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

  @HiveField(5)
  List<String> tags; // 🔥 Dynamic tags: ["CHEST", "PUSH", "#MORNING"]

  @HiveField(6)
  Map<String, int> tagColors; // 🎨 Tag name -> Color value (ARGB int)

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
    DateTime? createdAt,
    this.lastUsedAt,
    List<String>? tags,
    Map<String, int>? tagColors,
  }) : createdAt = createdAt ?? DateTime.now(),
       tags = tags ?? [],
       tagColors = tagColors ?? {};

  /// Routine 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Routine copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    List<String>? tags,
    Map<String, int>? tagColors,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises.map((e) => e.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      tags: tags ?? List.from(this.tags),
      tagColors: tagColors ?? Map.from(this.tagColors),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Routine &&
           other.id == id &&
           other.name == name &&
           listEquals(other.exercises, exercises) &&
           listEquals(other.tags, tags);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ exercises.hashCode ^ tags.hashCode;

  @override
  String toString() {
    return 'Routine(id: $id, name: $name, exercises: ${exercises.length}개, tags: $tags)';
  }
}

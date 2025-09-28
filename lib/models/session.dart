import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'exercise.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0)
  String ymd; // yyyy-MM-dd

  @HiveField(1)
  List<Exercise> exercises;

  @HiveField(2)
  bool isRest;

  @HiveField(3)
  int durationInSeconds;

  Session({
    required this.ymd,
    List<Exercise>? exercises,
    this.isRest = false,
    this.durationInSeconds = 0,
  }) : exercises = exercises ?? [];

  /// Session 객체를 복사하여 새로운 인스턴스를 생성합니다.
  Session copyWith({
    String? ymd,
    List<Exercise>? exercises,
    bool? isRest,
    int? durationInSeconds,
  }) {
    return Session(
      ymd: ymd ?? this.ymd,
      exercises: exercises ?? List.from(this.exercises),
      isRest: isRest ?? this.isRest,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
    );
  }

  /// 운동이 있는지 확인합니다.
  bool get hasExercises => exercises.isNotEmpty;

  /// 휴식일인지 확인합니다.
  bool get isWorkoutDay => !isRest && hasExercises;

  /// 총 운동 개수를 반환합니다.
  int get exerciseCount => exercises.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
           other.ymd == ymd &&
           other.isRest == isRest &&
           other.durationInSeconds == durationInSeconds &&
           listEquals(other.exercises, exercises);
  }

  @override
  int get hashCode => ymd.hashCode ^ isRest.hashCode ^ durationInSeconds.hashCode ^ exercises.hashCode;

  @override
  String toString() {
    return 'Session(ymd: $ymd, exercises: ${exercises.length}개, isRest: $isRest, duration: $durationInSeconds초)';
  }
}

extension SessionVolume on Session {
  /// 세션의 총 볼륨(무게 * 횟수 * 세트)을 계산합니다.
  double get totalVolume {
    double volume = 0;
    for (var exercise in exercises) {
      for (var set in exercise.sets) {
        volume += set.weight * set.reps;
      }
    }
    return volume;
  }
}

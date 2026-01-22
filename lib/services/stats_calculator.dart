import '../models/session.dart';

/// 운동 스탯 계산 서비스
class StatsCalculator {
  /// Epley 공식으로 1RM 계산
  /// 1RM = weight × (1 + reps / 30)
  static double calculate1RM(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  /// 특정 운동의 최고 1RM 찾기
  static double findBest1RM(List<Session> sessions, String exerciseName) {
    double best1RM = 0;
    
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        if (_matchExerciseName(exercise.name, exerciseName)) {
          for (final set in exercise.sets) {
            if (set.isCompleted && set.weight > 0 && set.reps > 0) {
              final estimated1RM = calculate1RM(set.weight, set.reps);
              if (estimated1RM > best1RM) {
                best1RM = estimated1RM;
              }
            }
          }
        }
      }
    }
    
    return best1RM;
  }

  /// 부위별 총 볼륨 계산
  static Map<String, double> calculateBodyPartVolumes(List<Session> sessions) {
    final volumes = <String, double>{
      'chest': 0,    // 가슴
      'back': 0,     // 등
      'legs': 0,     // 하체
      'shoulder': 0, // 어깨
      'arm': 0,      // 팔
      'core': 0,     // 코어
    };

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final category = _categorizeBodyPart(exercise.bodyPart);
        double exerciseVolume = 0;
        
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            exerciseVolume += set.weight * set.reps;
          }
        }
        
        volumes[category] = (volumes[category] ?? 0) + exerciseVolume;
      }
    }

    return volumes;
  }

  /// 총 운동 시간 (분) 계산
  static int calculateTotalWorkoutMinutes(List<Session> sessions) {
    int totalSeconds = 0;
    for (final session in sessions) {
      totalSeconds += session.durationInSeconds;
    }
    return totalSeconds ~/ 60;
  }

  /// 총 볼륨 계산
  static double calculateTotalVolume(List<Session> sessions) {
    double total = 0;
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            total += set.weight * set.reps;
          }
        }
      }
    }
    return total;
  }

  /// 레벨 계산 (총 볼륨 기반)
  static int calculateLevel(double totalVolume) {
    // 10,000kg당 1레벨
    return (totalVolume / 10000).floor() + 1;
  }

  /// 다음 레벨까지 필요한 볼륨
  static double volumeToNextLevel(double totalVolume) {
    final currentLevel = calculateLevel(totalVolume);
    final nextLevelVolume = currentLevel * 10000.0;
    return nextLevelVolume - totalVolume;
  }

  /// 레벨 진행률 (0.0 ~ 1.0)
  static double levelProgress(double totalVolume) {
    final currentLevel = calculateLevel(totalVolume);
    final prevLevelVolume = (currentLevel - 1) * 10000.0;
    final nextLevelVolume = currentLevel * 10000.0;
    return (totalVolume - prevLevelVolume) / (nextLevelVolume - prevLevelVolume);
  }

  /// 운동별 최고 기록 및 등급 계산
  static Map<String, ExerciseStats> calculateExerciseStats(List<Session> sessions) {
    final stats = <String, ExerciseStats>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final name = exercise.name;
        
        for (final set in exercise.sets) {
          if (set.isCompleted && set.weight > 0) {
            final estimated1RM = calculate1RM(set.weight, set.reps);
            
            if (!stats.containsKey(name) || estimated1RM > stats[name]!.best1RM) {
              stats[name] = ExerciseStats(
                name: name,
                bodyPart: exercise.bodyPart,
                best1RM: estimated1RM,
                bestWeight: set.weight,
                bestReps: set.reps,
              );
            }
          }
        }
      }
    }

    return stats;
  }

  /// 3대 운동 전투력 계산 (최적화)
  static BigThreeStats calculateBigThree(List<Session> sessions) {
    double bestBenchRM = 0;
    double bestSquatRM = 0;
    double bestDeadliftRM = 0;

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final isBench = _matchExerciseName(exercise.name, 'Bench Press');
        final isSquat = !isBench && _matchExerciseName(exercise.name, 'Squat');
        final isDeadlift = !isBench && !isSquat && _matchExerciseName(exercise.name, 'Deadlift');

        if (isBench || isSquat || isDeadlift) {
          for (final set in exercise.sets) {
            if (set.isCompleted && set.weight > 0 && set.reps > 0) {
              final estimated1RM = calculate1RM(set.weight, set.reps);
              if (isBench && estimated1RM > bestBenchRM) {
                bestBenchRM = estimated1RM;
              } else if (isSquat && estimated1RM > bestSquatRM) {
                bestSquatRM = estimated1RM;
              } else if (isDeadlift && estimated1RM > bestDeadliftRM) {
                bestDeadliftRM = estimated1RM;
              }
            }
          }
        }
      }
    }

    return BigThreeStats(
      benchPress: bestBenchRM,
      squat: bestSquatRM,
      deadlift: bestDeadliftRM,
    );
  }

  /// 운동 이름 매칭
  static bool _matchExerciseName(String stored, String search) {
    if (stored.toLowerCase() == search.toLowerCase()) return true;
    
    const nameMap = {
      'Bench Press': ['벤치프레스', 'ベンチプレス', 'bench press'],
      'Squat': ['스쿼트', 'スクワット', 'squat'],
      'Deadlift': ['데드리프트', 'デッドリフト', 'deadlift'],
    };

    for (final entry in nameMap.entries) {
      if (entry.key.toLowerCase() == search.toLowerCase() ||
          entry.value.any((v) => v.toLowerCase() == search.toLowerCase())) {
        if (entry.key.toLowerCase() == stored.toLowerCase() ||
            entry.value.any((v) => v.toLowerCase() == stored.toLowerCase())) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// 부위 카테고리화
  static String _categorizeBodyPart(String bodyPart) {
    final lower = bodyPart.toLowerCase();
    
    if (lower.contains('가슴') || lower.contains('chest')) return 'chest';
    if (lower.contains('등') || lower.contains('back')) return 'back';
    if (lower.contains('하체') || lower.contains('leg') || lower.contains('다리')) return 'legs';
    if (lower.contains('어깨') || lower.contains('shoulder')) return 'shoulder';
    if (lower.contains('팔') || lower.contains('arm') || lower.contains('이두') || lower.contains('삼두')) return 'arm';
    if (lower.contains('복근') || lower.contains('코어') || lower.contains('core') || lower.contains('abs')) return 'core';
    
    return 'core'; // 기본값
  }
}

/// 운동별 스탯
class ExerciseStats {
  final String name;
  final String bodyPart;
  final double best1RM;
  final double bestWeight;
  final int bestReps;

  ExerciseStats({
    required this.name,
    required this.bodyPart,
    required this.best1RM,
    required this.bestWeight,
    required this.bestReps,
  });

  /// 등급 계산
  String get rank {
    if (best1RM >= 200) return 'Vibranium';
    if (best1RM >= 150) return 'Diamond';
    if (best1RM >= 120) return 'Platinum';
    if (best1RM >= 100) return 'Gold';
    if (best1RM >= 80) return 'Silver';
    if (best1RM >= 60) return 'Bronze';
    return 'Beginner';
  }

  /// 등급 색상
  int get rankColor {
    switch (rank) {
      case 'Vibranium': return 0xFFE91E63; // Pink
      case 'Diamond': return 0xFF00BCD4;   // Cyan
      case 'Platinum': return 0xFF9E9E9E;  // Silver
      case 'Gold': return 0xFFFFD700;      // Gold
      case 'Silver': return 0xFFC0C0C0;    // Silver
      case 'Bronze': return 0xFFCD7F32;    // Bronze
      default: return 0xFF666666;          // Grey
    }
  }
}

/// 3대 운동 스탯
class BigThreeStats {
  final double benchPress;
  final double squat;
  final double deadlift;

  BigThreeStats({
    required this.benchPress,
    required this.squat,
    required this.deadlift,
  });

  double get total => benchPress + squat + deadlift;
}

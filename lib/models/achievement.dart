import 'package:flutter/material.dart';

enum AchievementType {
  streak,      // 연속 운동
  volume,      // 총 볼륨
  workout,     // 운동 횟수
  exercise,    // 운동 종류
  special,     // 특별 업적
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int requirement;  // 달성 조건 (숫자)
  final bool Function(AchievementStats stats) checkUnlock;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requirement,
    required this.checkUnlock,
  });
}

class AchievementStats {
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final double totalVolume;
  final int uniqueExercises;
  final int totalSets;
  final bool hasWeekendWorkout;
  final bool hasEarlyMorningWorkout;

  const AchievementStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWorkouts = 0,
    this.totalVolume = 0,
    this.uniqueExercises = 0,
    this.totalSets = 0,
    this.hasWeekendWorkout = false,
    this.hasEarlyMorningWorkout = false,
  });
}

// 모든 업적 정의
class Achievements {
  static final List<Achievement> all = [
    // 🔥 스트릭 업적
    Achievement(
      id: 'streak_3',
      title: '시작이 반이다',
      description: '3일 연속 운동',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF6B35),
      type: AchievementType.streak,
      requirement: 3,
      checkUnlock: (s) => s.longestStreak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: '일주일 전사',
      description: '7일 연속 운동',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF6B35),
      type: AchievementType.streak,
      requirement: 7,
      checkUnlock: (s) => s.longestStreak >= 7,
    ),
    Achievement(
      id: 'streak_30',
      title: '한 달의 기적',
      description: '30일 연속 운동',
      icon: Icons.whatshot,
      color: const Color(0xFFFF3B30),
      type: AchievementType.streak,
      requirement: 30,
      checkUnlock: (s) => s.longestStreak >= 30,
    ),
    
    // 💪 운동 횟수 업적
    Achievement(
      id: 'workout_1',
      title: '첫 발걸음',
      description: '첫 운동 완료',
      icon: Icons.emoji_events,
      color: const Color(0xFF34C759),
      type: AchievementType.workout,
      requirement: 1,
      checkUnlock: (s) => s.totalWorkouts >= 1,
    ),
    Achievement(
      id: 'workout_10',
      title: '습관 형성',
      description: '10회 운동 완료',
      icon: Icons.fitness_center,
      color: const Color(0xFF34C759),
      type: AchievementType.workout,
      requirement: 10,
      checkUnlock: (s) => s.totalWorkouts >= 10,
    ),
    Achievement(
      id: 'workout_50',
      title: '운동 마니아',
      description: '50회 운동 완료',
      icon: Icons.military_tech,
      color: const Color(0xFF007AFF),
      type: AchievementType.workout,
      requirement: 50,
      checkUnlock: (s) => s.totalWorkouts >= 50,
    ),
    Achievement(
      id: 'workout_100',
      title: '백전백승',
      description: '100회 운동 완료',
      icon: Icons.workspace_premium,
      color: const Color(0xFFAF52DE),
      type: AchievementType.workout,
      requirement: 100,
      checkUnlock: (s) => s.totalWorkouts >= 100,
    ),
    
    // 🏋️ 볼륨 업적
    Achievement(
      id: 'volume_10k',
      title: '만 킬로그램',
      description: '총 볼륨 10,000kg 달성',
      icon: Icons.speed,
      color: const Color(0xFFFFCC00),
      type: AchievementType.volume,
      requirement: 10000,
      checkUnlock: (s) => s.totalVolume >= 10000,
    ),
    Achievement(
      id: 'volume_100k',
      title: '10만 클럽',
      description: '총 볼륨 100,000kg 달성',
      icon: Icons.rocket_launch,
      color: const Color(0xFFFFCC00),
      type: AchievementType.volume,
      requirement: 100000,
      checkUnlock: (s) => s.totalVolume >= 100000,
    ),
    Achievement(
      id: 'volume_1m',
      title: '밀리언 리프터',
      description: '총 볼륨 1,000,000kg 달성',
      icon: Icons.diamond,
      color: const Color(0xFFFF2D55),
      type: AchievementType.volume,
      requirement: 1000000,
      checkUnlock: (s) => s.totalVolume >= 1000000,
    ),
    
    // 🎯 특별 업적
    Achievement(
      id: 'weekend_warrior',
      title: '주말 전사',
      description: '주말에 운동하기',
      icon: Icons.weekend,
      color: const Color(0xFF5856D6),
      type: AchievementType.special,
      requirement: 1,
      checkUnlock: (s) => s.hasWeekendWorkout,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter/material.dart';

// 리그 등급
enum League {
  bronze(name: '브론즈', icon: '🥉', color: Color(0xFFCD7F32), minXP: 0),
  silver(name: '실버', icon: '🥈', color: Color(0xFFC0C0C0), minXP: 500),
  gold(name: '골드', icon: '🥇', color: Color(0xFFFFD700), minXP: 1500),
  platinum(name: '플래티넘', icon: '💎', color: Color(0xFF00CED1), minXP: 3500),
  diamond(name: '다이아몬드', icon: '💠', color: Color(0xFF00BFFF), minXP: 7000),
  master(name: '마스터', icon: '👑', color: Color(0xFFFF6B35), minXP: 15000);

  final String name;
  final String icon;
  final Color color;
  final int minXP;

  const League({
    required this.name,
    required this.icon,
    required this.color,
    required this.minXP,
  });

  // 다음 리그
  League? get next {
    final idx = League.values.indexOf(this);
    if (idx < League.values.length - 1) {
      return League.values[idx + 1];
    }
    return null;
  }

  // XP로 리그 결정
  static League fromXP(int totalXP) {
    for (int i = League.values.length - 1; i >= 0; i--) {
      if (totalXP >= League.values[i].minXP) {
        return League.values[i];
      }
    }
    return League.bronze;
  }
}

// 레벨 계산
class LevelSystem {
  // 레벨업에 필요한 XP (레벨이 올라갈수록 증가)
  static int xpForLevel(int level) {
    return 100 + (level - 1) * 50; // 레벨1: 100, 레벨2: 150, 레벨3: 200...
  }

  // 총 XP로 현재 레벨 계산
  static int levelFromTotalXP(int totalXP) {
    int level = 1;
    int xpNeeded = 0;
    while (true) {
      xpNeeded += xpForLevel(level);
      if (totalXP < xpNeeded) break;
      level++;
    }
    return level;
  }

  // 현재 레벨에서의 진행도 (0.0 ~ 1.0)
  static double progressInLevel(int totalXP) {
    int level = 1;
    int xpUsed = 0;
    while (true) {
      final needed = xpForLevel(level);
      if (totalXP < xpUsed + needed) {
        return (totalXP - xpUsed) / needed;
      }
      xpUsed += needed;
      level++;
    }
  }

  // 다음 레벨까지 남은 XP
  static int xpToNextLevel(int totalXP) {
    int level = 1;
    int xpUsed = 0;
    while (true) {
      final needed = xpForLevel(level);
      if (totalXP < xpUsed + needed) {
        return (xpUsed + needed) - totalXP;
      }
      xpUsed += needed;
      level++;
    }
  }
}

// XP 획득 규칙
class XPRules {
  static const int perSet = 10;           // 세트당 10 XP
  static const int perExercise = 20;      // 운동 종류당 20 XP
  static const int dailyGoalBonus = 50;   // 일일 목표 달성 보너스
  static const int streakBonus = 25;      // 스트릭 보너스 (연속일 * 25)
  static const int perfectWeekBonus = 200; // 7일 연속 보너스

  // 운동 세션에서 XP 계산
  static int calculateSessionXP({
    required int setCount,
    required int exerciseCount,
    required bool dailyGoalMet,
    required int currentStreak,
  }) {
    int xp = 0;
    xp += setCount * perSet;
    xp += exerciseCount * perExercise;
    if (dailyGoalMet) xp += dailyGoalBonus;
    if (currentStreak > 0) xp += (currentStreak * streakBonus).clamp(0, 175); // 최대 7일치
    if (currentStreak == 7) xp += perfectWeekBonus;
    return xp;
  }
}

// 유저 게임 데이터
class UserGameData {
  final int totalXP;
  final int weeklyXP;
  final int power; // 💪 파워 (구 젬)
  final int freezes; // 스트릭 프리즈 아이템
  final DateTime? lastWorkoutDate;

  const UserGameData({
    this.totalXP = 0,
    this.weeklyXP = 0,
    this.power = 0,
    this.freezes = 1, // 시작 시 1개 제공
    this.lastWorkoutDate,
  });

  int get level => LevelSystem.levelFromTotalXP(totalXP);
  double get levelProgress => LevelSystem.progressInLevel(totalXP);
  int get xpToNextLevel => LevelSystem.xpToNextLevel(totalXP);
  League get league => League.fromXP(totalXP);

  UserGameData copyWith({
    int? totalXP,
    int? weeklyXP,
    int? power,
    int? freezes,
    DateTime? lastWorkoutDate,
  }) {
    return UserGameData(
      totalXP: totalXP ?? this.totalXP,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      power: power ?? this.power,
      freezes: freezes ?? this.freezes,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalXP': totalXP,
    'weeklyXP': weeklyXP,
    'power': power,
    'freezes': freezes,
    'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
  };

  factory UserGameData.fromJson(Map<String, dynamic> json) => UserGameData(
    totalXP: json['totalXP'] ?? json['gems'] ?? 0, // 기존 gems 호환
    weeklyXP: json['weeklyXP'] ?? 0,
    power: json['power'] ?? json['gems'] ?? 0, // 기존 gems 호환
    freezes: json['freezes'] ?? 1,
    lastWorkoutDate: json['lastWorkoutDate'] != null 
        ? DateTime.parse(json['lastWorkoutDate']) 
        : null,
  );
}

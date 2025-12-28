import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement.dart';
import '../models/session.dart';
import '../data/session_repo.dart';

class AchievementService {
  static const String boxName = 'achievements';
  late Box<String> _box;
  final SessionRepo sessionRepo;

  AchievementService({required this.sessionRepo});

  Future<void> init() async {
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<String>(boxName);
    } else {
      _box = await Hive.openBox<String>(boxName);
    }
  }

  // 해금된 업적 ID 목록
  List<String> get unlockedIds => _box.values.toList();

  // 업적 해금 여부
  bool isUnlocked(String id) => _box.containsKey(id);

  // 업적 해금
  Future<void> unlock(String id) async {
    if (!isUnlocked(id)) {
      await _box.put(id, DateTime.now().toIso8601String());
    }
  }

  // 현재 통계 계산
  Future<AchievementStats> calculateStats() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    if (sessions.isEmpty) return const AchievementStats();

    // 날짜별 정렬
    sessions.sort((a, b) => b.ymd.compareTo(a.ymd));

    // 총 운동 횟수
    final totalWorkouts = sessions.length;

    // 총 볼륨
    final totalVolume = sessions.fold<double>(0, (sum, s) => sum + s.totalVolume);

    // 총 세트
    final totalSets = sessions.fold<int>(0, (sum, s) => 
      sum + s.exercises.fold<int>(0, (eSum, e) => eSum + e.sets.length));

    // 고유 운동 종류
    final uniqueExercises = <String>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        uniqueExercises.add(exercise.name);
      }
    }

    // 스트릭 계산
    final today = DateTime.now();
    final todayYmd = sessionRepo.ymd(today);
    final yesterdayYmd = sessionRepo.ymd(today.subtract(const Duration(days: 1)));

    int currentStreak = 0;
    DateTime checkDate = today;

    final hasToday = sessions.any((s) => s.ymd == todayYmd);
    final hasYesterday = sessions.any((s) => s.ymd == yesterdayYmd);

    if (hasToday || hasYesterday) {
      if (!hasToday) checkDate = today.subtract(const Duration(days: 1));
      
      while (true) {
        final ymd = sessionRepo.ymd(checkDate);
        if (sessions.any((s) => s.ymd == ymd)) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // 최장 스트릭
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    for (final session in sessions.reversed.toList()) {
      final date = sessionRepo.ymdToDateTime(session.ymd);
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diff = prevDate.difference(date).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
      prevDate = date;
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // 주말 운동 여부
    bool hasWeekendWorkout = false;
    for (final session in sessions) {
      final date = sessionRepo.ymdToDateTime(session.ymd);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        hasWeekendWorkout = true;
        break;
      }
    }

    return AchievementStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalWorkouts: totalWorkouts,
      totalVolume: totalVolume,
      uniqueExercises: uniqueExercises.length,
      totalSets: totalSets,
      hasWeekendWorkout: hasWeekendWorkout,
    );
  }

  // 새로 해금된 업적 확인
  Future<List<Achievement>> checkNewUnlocks() async {
    final stats = await calculateStats();
    final newUnlocks = <Achievement>[];

    for (final achievement in Achievements.all) {
      if (!isUnlocked(achievement.id) && achievement.checkUnlock(stats)) {
        await unlock(achievement.id);
        newUnlocks.add(achievement);
      }
    }

    return newUnlocks;
  }

  // 해금된 업적 목록
  List<Achievement> getUnlockedAchievements() {
    return Achievements.all.where((a) => isUnlocked(a.id)).toList();
  }

  // 진행 중인 업적 (다음 목표)
  List<Achievement> getInProgressAchievements() {
    return Achievements.all.where((a) => !isUnlocked(a.id)).toList();
  }
}

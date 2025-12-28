import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gamification.dart';
import '../models/session.dart';
import '../data/session_repo.dart';

class GamificationService {
  static const String boxName = 'gamification';
  static const String dataKey = 'user_game_data';
  late Box<String> _box;
  final SessionRepo sessionRepo;

  UserGameData _data = const UserGameData();
  UserGameData get data => _data;

  GamificationService({required this.sessionRepo});

  Future<void> init() async {
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<String>(boxName);
    } else {
      _box = await Hive.openBox<String>(boxName);
    }
    await _loadData();
    await _recalculateFromSessions(); // 세션 기반으로 XP 재계산
  }

  Future<void> _loadData() async {
    final jsonStr = _box.get(dataKey);
    if (jsonStr != null) {
      _data = UserGameData.fromJson(jsonDecode(jsonStr));
    }
  }

  Future<void> _saveData() async {
    await _box.put(dataKey, jsonEncode(_data.toJson()));
  }

  // 세션 데이터 기반으로 XP 재계산
  Future<void> _recalculateFromSessions() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    if (sessions.isEmpty) return;

    int totalXP = 0;
    int weeklyXP = 0;

    // 이번 주 시작일
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekYmd = sessionRepo.ymd(startOfWeek);

    // 스트릭 계산
    sessions.sort((a, b) => a.ymd.compareTo(b.ymd));
    
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final setCount = session.exercises.fold<int>(0, (sum, e) => sum + e.sets.length);
      final exerciseCount = session.exercises.length;
      
      // 스트릭 계산 (해당 시점까지의 연속일)
      int streak = 1;
      if (i > 0) {
        final prevDate = sessionRepo.ymdToDateTime(sessions[i - 1].ymd);
        final currDate = sessionRepo.ymdToDateTime(session.ymd);
        if (currDate.difference(prevDate).inDays == 1) {
          streak = _calculateStreakAt(sessions, i);
        }
      }

      final sessionXP = XPRules.calculateSessionXP(
        setCount: setCount,
        exerciseCount: exerciseCount,
        dailyGoalMet: setCount >= 10, // 10세트 이상이면 일일 목표 달성
        currentStreak: streak,
      );

      totalXP += sessionXP;

      // 이번 주 XP
      if (session.ymd.compareTo(startOfWeekYmd) >= 0) {
        weeklyXP += sessionXP;
      }
    }

    // 파워: 100 XP당 1파워
    final power = totalXP ~/ 100;

    _data = _data.copyWith(
      totalXP: totalXP,
      weeklyXP: weeklyXP,
      power: power,
      lastWorkoutDate: sessions.isNotEmpty 
          ? sessionRepo.ymdToDateTime(sessions.last.ymd)
          : null,
    );

    await _saveData();
  }

  int _calculateStreakAt(List<Session> sessions, int index) {
    int streak = 1;
    for (int i = index; i > 0; i--) {
      final curr = sessionRepo.ymdToDateTime(sessions[i].ymd);
      final prev = sessionRepo.ymdToDateTime(sessions[i - 1].ymd);
      if (curr.difference(prev).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // 운동 완료 시 XP 추가
  Future<int> addWorkoutXP({
    required int setCount,
    required int exerciseCount,
    required int currentStreak,
  }) async {
    final xp = XPRules.calculateSessionXP(
      setCount: setCount,
      exerciseCount: exerciseCount,
      dailyGoalMet: setCount >= 10,
      currentStreak: currentStreak,
    );

    final newPower = ((_data.totalXP + xp) ~/ 100) - (_data.totalXP ~/ 100);

    _data = _data.copyWith(
      totalXP: _data.totalXP + xp,
      weeklyXP: _data.weeklyXP + xp,
      power: _data.power + newPower,
      lastWorkoutDate: DateTime.now(),
    );

    await _saveData();
    return xp;
  }

  // 스트릭 프리즈 사용
  Future<bool> useFreeze() async {
    if (_data.freezes <= 0) return false;
    _data = _data.copyWith(freezes: _data.freezes - 1);
    await _saveData();
    return true;
  }

  // 파워로 프리즈 구매 (50파워)
  Future<bool> buyFreeze() async {
    if (_data.power < 50) return false;
    _data = _data.copyWith(
      power: _data.power - 50,
      freezes: _data.freezes + 1,
    );
    await _saveData();
    return true;
  }

  // 주간 XP 리셋 (매주 월요일)
  Future<void> resetWeeklyXP() async {
    _data = _data.copyWith(weeklyXP: 0);
    await _saveData();
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    await _recalculateFromSessions();
  }
}

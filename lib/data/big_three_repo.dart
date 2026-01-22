import 'session_repo.dart';

/// Big 3 운동 타입 (Squat, Bench Press, Deadlift)
enum Big3Type {
  squat,
  bench,
  deadlift,
}

/// Big 3 개인 기록 데이터
class Big3Record {
  final Big3Type type;
  final double currentMax; // 현재 최고 기록
  final double previousMax; // 이전 최고 기록 (두 번째로 높은 기록)
  final DateTime? lastRecordDate; // 마지막 기록 날짜
  final List<Big3HistoryPoint> history; // 히스토리 데이터 (차트용)
  
  Big3Record({
    required this.type,
    required this.currentMax,
    required this.previousMax,
    this.lastRecordDate,
    required this.history,
  });
  
  /// 이전 기록 대비 증가량
  double get improvement => currentMax - previousMax;
  
  /// 증가가 있는지 여부
  bool get hasImprovement => improvement > 0;
  
  /// 기록이 있는지 여부
  bool get hasData => currentMax > 0;
}

/// Big 3 히스토리 포인트 (차트용)
class Big3HistoryPoint {
  final DateTime date;
  final double maxWeight;
  
  Big3HistoryPoint({
    required this.date,
    required this.maxWeight,
  });
}

/// Big 3 전체 데이터
class Big3Data {
  final Big3Record squat;
  final Big3Record bench;
  final Big3Record deadlift;
  
  Big3Data({
    required this.squat,
    required this.bench,
    required this.deadlift,
  });
  
  /// 총합 (SBD Total)
  double get total => squat.currentMax + bench.currentMax + deadlift.currentMax;
  
  /// 데이터가 있는지 여부
  bool get hasData => squat.hasData || bench.hasData || deadlift.hasData;
}

/// Big Three Repository - PR 추적 및 히스토리 관리
class BigThreeRepository {
  final SessionRepo sessionRepo;
  
  BigThreeRepository({required this.sessionRepo});
  
  /// Big 3 전체 데이터 가져오기
  Future<Big3Data> getBig3Data() async {
    final squat = await getPersonalRecord(Big3Type.squat);
    final bench = await getPersonalRecord(Big3Type.bench);
    final deadlift = await getPersonalRecord(Big3Type.deadlift);
    
    return Big3Data(
      squat: squat,
      bench: bench,
      deadlift: deadlift,
    );
  }
  
  /// 특정 운동의 개인 기록 가져오기
  Future<Big3Record> getPersonalRecord(Big3Type type) async {
    final sessions = await sessionRepo.getWorkoutSessions();
    
    // 해당 운동의 모든 기록 수집
    final Map<DateTime, double> recordsByDate = {};
    
    for (final session in sessions) {
      final sessionDate = sessionRepo.ymdToDateTime(session.ymd);
      double sessionMax = 0;
      
      for (final exercise in session.exercises) {
        if (_isMatchingExercise(exercise.name, type)) {
          // 해당 세션에서 최고 무게 찾기
          for (final set in exercise.sets) {
            if (set.weight > sessionMax) {
              sessionMax = set.weight;
            }
          }
        }
      }
      
      // 해당 날짜의 최고 기록 저장
      if (sessionMax > 0) {
        final normalizedDate = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
        if (!recordsByDate.containsKey(normalizedDate) || recordsByDate[normalizedDate]! < sessionMax) {
          recordsByDate[normalizedDate] = sessionMax;
        }
      }
    }
    
    // 기록이 없는 경우
    if (recordsByDate.isEmpty) {
      return Big3Record(
        type: type,
        currentMax: 0,
        previousMax: 0,
        history: [],
      );
    }
    
    // 날짜순 정렬
    final sortedEntries = recordsByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // 히스토리 데이터 생성 (최근 6개월)
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final history = sortedEntries
        .where((entry) => entry.key.isAfter(sixMonthsAgo))
        .map((entry) => Big3HistoryPoint(
              date: entry.key,
              maxWeight: entry.value,
            ))
        .toList();
    
    // 현재 최고 기록 (전체 기간)
    final currentMax = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    
    // 이전 최고 기록 (두 번째로 높은 고유 값)
    final uniqueWeights = recordsByDate.values.toSet().toList()..sort((a, b) => b.compareTo(a));
    final previousMax = uniqueWeights.length > 1 ? uniqueWeights[1].toDouble() : 0.0;
    
    // 마지막 기록 날짜 (최고 기록을 달성한 날짜)
    final lastRecordDate = sortedEntries
        .lastWhere((entry) => entry.value == currentMax)
        .key;
    
    return Big3Record(
      type: type,
      currentMax: currentMax,
      previousMax: previousMax,
      lastRecordDate: lastRecordDate,
      history: history,
    );
  }
  
  /// 운동 이름이 Big 3 타입과 일치하는지 확인 (다국어 지원)
  bool _isMatchingExercise(String exerciseName, Big3Type type) {
    final name = exerciseName.toLowerCase();
    
    switch (type) {
      case Big3Type.squat:
        return name.contains('squat') || 
               name.contains('스쿼트') || 
               name.contains('スクワット');
      
      case Big3Type.bench:
        return name.contains('bench') || 
               name.contains('벤치') || 
               name.contains('ベンチ');
      
      case Big3Type.deadlift:
        return name.contains('deadlift') || 
               name.contains('데드리프트') || 
               name.contains('デッドリフト');
    }
  }
  
  /// Big 3 타입의 표시 이름 가져오기
  static String getDisplayName(Big3Type type) {
    switch (type) {
      case Big3Type.squat:
        return 'SQUAT';
      case Big3Type.bench:
        return 'BENCH PRESS';
      case Big3Type.deadlift:
        return 'DEADLIFT';
    }
  }
}

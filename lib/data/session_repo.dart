import 'package:hive_flutter/hive_flutter.dart';
import '../models/session.dart';
import '../models/exercise_set.dart';
import '../models/exercise.dart';
import '../core/constants.dart';
import 'package:intl/intl.dart';

/// 운동 기록 히스토리 항목
class ExerciseHistoryRecord {
  final String date; // yyyy-MM-dd
  final List<ExerciseSet> sets;
  
  ExerciseHistoryRecord({
    required this.date,
    required this.sets,
  });
  
  /// 최고 무게 반환
  double get maxWeight => sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  
  /// 총 볼륨 계산
  double get totalVolume => sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  
  /// 총 세트 수
  int get totalSets => sets.length;
  
  /// 날짜를 MM/dd 형식으로 포맷
  String get formattedDate {
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MM/dd').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}

/// 세션 데이터 저장소 인터페이스
abstract class SessionRepo {
  /// 저장소 초기화
  Future<void> init();
  
  /// DateTime을 yyyy-MM-dd 형식의 문자열로 변환
  String ymd(DateTime d);

  /// yyyy-MM-dd 형식의 문자열을 DateTime으로 변환
  DateTime ymdToDateTime(String ymd);
  
  /// 특정 날짜의 세션을 조회
  Future<Session?> get(String ymd);
  
  /// 세션을 저장
  Future<void> put(Session s);
  
  /// 세션을 삭제
  Future<void> delete(String ymd);

  /// 모든 세션 데이터 삭제
  Future<void> clearAllData();
  
  /// 모든 세션을 조회 (날짜순 정렬)
  Future<List<Session>> listAll();
  
  /// 휴식일로 표시/해제
  Future<void> markRest(String ymd, {required bool rest});
  
  /// 다른 날짜의 세션을 복사
  Future<void> copyDay({
    required String fromYmd,
    required String toYmd,
    List<int>? pickIndexes,
  });
  
  /// 특정 기간의 세션들을 조회
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end);
  
  /// 운동 기록이 있는 날짜들만 조회
  Future<List<Session>> getWorkoutSessions();
  
  /// 특정 운동의 최근 기록들을 조회 (최대 5개)
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5});
}

class HiveSessionRepo implements SessionRepo {
  static const boxName = 'sessions';
  late Box<Session> _box;

  @override
  Future<void> init() async {
    // 어댑터 중복 등록 방지
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

    // 앱에선 initFlutter, 테스트에서 이미 Hive.init(...)된 경우 예외 무시
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    // 이미 열려 있으면 재사용, 아니면 오픈
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<Session>(boxName);
    } else {
      _box = await Hive.openBox<Session>(boxName);
    }
  }

  @override
  String ymd(DateTime d) => DateFormat(AppConstants.dateFormat).format(d);

  @override
  DateTime ymdToDateTime(String ymd) => DateFormat(AppConstants.dateFormat).parse(ymd);

  @override
  Future<Session?> get(String ymd) async => _box.get(ymd);

  @override
  Future<void> put(Session s) async => _box.put(s.ymd, s);

  @override
  Future<void> delete(String ymd) async => _box.delete(ymd);

  @override
  Future<void> clearAllData() async => _box.clear();

  @override
  Future<List<Session>> listAll() async {
    final list = _box.values.toList();
    list.sort((a, b) => a.ymd.compareTo(b.ymd));
    return list;
  }

  @override
  Future<void> markRest(String ymd, {required bool rest}) async {
    final existing = await get(ymd);
    if (existing != null) {
      existing.isRest = rest;
      if (rest) existing.exercises.clear();
      await put(existing);
    } else {
      await put(Session(ymd: ymd, isRest: rest));
    }
  }

  @override
  Future<void> copyDay({
    required String fromYmd,
    required String toYmd,
    List<int>? pickIndexes,
  }) async {
    try {
      final from = await get(fromYmd);
      if (from == null || (from.exercises.isEmpty && !from.isRest)) {
        throw StateError('복사할 세션이 없습니다: $fromYmd');
      }

      final picked = pickIndexes == null
          ? from.exercises
          : [
              for (final i in pickIndexes)
                if (i >= 0 && i < from.exercises.length)
                  from.exercises[i].copyWith(),
            ];

      await put(Session(ymd: toYmd, exercises: List.of(picked), isRest: false));
    } catch (e) {
      throw Exception('세션 복사 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) async {
    try {
      final allSessions = await listAll();
      final startYmd = ymd(start);
      final endYmd = ymd(end);
      
      return allSessions.where((session) {
        return session.ymd.compareTo(startYmd) >= 0 && 
               session.ymd.compareTo(endYmd) <= 0;
      }).toList();
    } catch (e) {
      throw Exception('기간별 세션 조회 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<Session>> getWorkoutSessions() async {
    try {
      final allSessions = await listAll();
      final workoutSessions = allSessions.where((session) {
        try {
          return session.isWorkoutDay;
        } catch (e) {
          print('⚠️ 세션 확인 중 오류: ${session.ymd}, $e');
          return false;
        }
      }).toList();
      return workoutSessions;
    } catch (e) {
      print('❌ 운동 세션 조회 중 오류: $e');
      return [];
    }
  }

  @override
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5}) async {
    try {
      final allSessions = await listAll();
      final records = <ExerciseHistoryRecord>[];
      
      // 최신 날짜부터 역순으로 정렬
      allSessions.sort((a, b) => b.ymd.compareTo(a.ymd));
      
      for (final session in allSessions) {
        if (records.length >= limit) break;
        
        // 해당 운동이 있는지 확인
        final exercise = session.exercises.where((ex) => ex.name == exerciseName).firstOrNull;
        if (exercise != null && exercise.sets.isNotEmpty) {
          // 완료된 세트만 필터링
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          if (completedSets.isNotEmpty) {
            records.add(ExerciseHistoryRecord(
              date: session.ymd,
              sets: completedSets,
            ));
          }
        }
      }
      
      return records;
    } catch (e) {
      print('❌ 운동 기록 조회 중 오류: $e');
      return [];
    }
  }
}

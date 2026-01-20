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
  final String? memo; // 메모 추가
  
  ExerciseHistoryRecord({
    required this.date,
    required this.sets,
    this.memo,
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
  
  /// 운동 기록이 있는 날짜들만 조회 (전체 세션 객체 로드)
  Future<List<Session>> getWorkoutSessions();

  /// 운동 기록이 있는 모든 날짜 조회 (최적화)
  Future<Set<String>> getAllWorkoutDates();

  /// 휴식일로 지정된 모든 날짜 조회 (최적화)
  Future<Set<String>> getAllRestDates();
  
  /// 특정 운동의 최근 기록들을 조회 (최대 5개)
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5});
  
  /// 테스트용 더미 데이터 생성
  Future<void> seedDummyWorkoutData();
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
      final startYmd = ymd(start);
      final endYmd = ymd(end);
      
      // Hive의 lazy iterable을 직접 사용하여 메모리 효율성 증대
      final sessions = _box.values.where((session) {
        return session.ymd.compareTo(startYmd) >= 0 && 
               session.ymd.compareTo(endYmd) <= 0;
      }).toList();
      // listAll()이 수행하던 정렬을 여기서 직접 수행
      sessions.sort((a, b) => a.ymd.compareTo(b.ymd));
      return sessions;
    } catch (e) {
      throw Exception('기간별 세션 조회 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<List<Session>> getWorkoutSessions() async {
    try {
      // .values는 lazy iterable. listAll()을 호출해 전체를 메모리에 올릴 필요 없음
      final workoutSessions = _box.values.where((session) {
        try {
          return session.isWorkoutDay;
        } catch (e) {
          print('⚠️ 세션 확인 중 오류: ${session.ymd}, $e');
          return false;
        }
      }).toList();
      // listAll()이 수행하던 정렬을 여기서 직접 수행
      workoutSessions.sort((a, b) => a.ymd.compareTo(b.ymd));
      return workoutSessions;
    } catch (e) {
      print('❌ 운동 세션 조회 중 오류: $e');
      return [];
    }
  }

  @override
  Future<Set<String>> getAllWorkoutDates() async {
    try {
      // .values는 lazy iterable이므로 전체 객체를 메모리에 로드하지 않음
      return _box.values
          .where((session) => session.isWorkoutDay)
          .map((session) => session.ymd)
          .toSet();
    } catch (e) {
      print('❌ 운동 날짜 조회 중 오류: $e');
      return {};
    }
  }

  @override
  Future<Set<String>> getAllRestDates() async {
    try {
      return _box.values
          .where((session) => session.isRest)
          .map((session) => session.ymd)
          .toSet();
    } catch (e) {
      print('❌ 휴식 날짜 조회 중 오류: $e');
      return {};
    }
  }

  @override
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5}) async {
    try {
      final records = <ExerciseHistoryRecord>[];
      
      // 최신 기록부터 조회하기 위해 key(날짜)를 역순으로 정렬
      final sortedKeys = _box.keys.cast<String>().toList()
        ..sort((a, b) => b.compareTo(a));

      for (final key in sortedKeys) {
        if (records.length >= limit) break;

        final session = await _box.get(key);
        if (session == null) continue;
        
        // 해당 운동이 있는지 확인 (다국어 매칭 지원)
        final matches = session.exercises.where((ex) => _isExerciseNameMatch(ex.name, exerciseName));
        final exercise = matches.isEmpty ? null : matches.first;

        if (exercise != null && exercise.sets.isNotEmpty) {
          print('✅ 매칭된 운동 발견: ${exercise.name}, 세트 수: ${exercise.sets.length}');
          
          // 완료된 세트만 필터링
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          print('  - 완료된 세트 수: ${completedSets.length}');
          
          if (completedSets.isNotEmpty) {
            records.add(ExerciseHistoryRecord(
              date: session.ymd,
              sets: completedSets,
              memo: exercise.memo, // 메모 추가
            ));
            print('  - 기록 추가됨: ${session.ymd}, 메모: ${exercise.memo ?? "없음"}');
          }
        }
      }
      
      print('🔍 최종 기록 수: ${records.length}');
      return records;
    } catch (e) {
      print('❌ 운동 기록 조회 중 오류: $e');
      return [];
    }
  }

  /// 운동 이름 매칭 (다국어 지원)
  bool _isExerciseNameMatch(String storedName, String searchName) {
    // 정확한 매칭
    if (storedName == searchName) return true;
    
    // 다국어 매칭 - ExerciseDB의 매핑을 활용
    // 영어 → 한국어/일본어 매칭
    const exerciseNameMap = {
      'Bench Press': ['벤치프레스', 'ベンチプレス'],
      'Squat': ['스쿼트', 'スクワット'],
      'Deadlift': ['데드리프트', 'デッドリフト'],
      'Lat Pulldown': ['랫풀다운', 'ラットプルダウン'],
      'Incline Dumbbell Press': ['인클라인 덤벨 프레스', 'インクライン・ダンベル・プレス'],
      'Leg Press': ['레그 프레스', 'レッグプレス'],
    };
    
    // 저장된 이름이 영어인 경우, 검색 이름이 번역된 이름인지 확인
    if (exerciseNameMap.containsKey(storedName)) {
      return exerciseNameMap[storedName]!.contains(searchName);
    }
    
    // 검색 이름이 영어인 경우, 저장된 이름이 번역된 이름인지 확인
    if (exerciseNameMap.containsKey(searchName)) {
      return exerciseNameMap[searchName]!.contains(storedName);
    }
    
    // 번역된 이름들 간의 매칭
    for (final entry in exerciseNameMap.entries) {
      final translations = entry.value;
      if (translations.contains(storedName) && translations.contains(searchName)) {
        return true;
      }
    }
    
    return false;
  }

  @override
  Future<void> seedDummyWorkoutData() async {
    try {
      final now = DateTime.now();
      
      // 지난 2주간의 더미 운동 데이터 생성 (영어 원본명 사용)
      final dummySessions = [
        // 7일 전 - 벤치프레스, 스쿼트
        Session(
          ymd: ymd(now.subtract(const Duration(days: 7))),
          exercises: [
            Exercise(
              name: 'Bench Press', // 영어 원본명
              bodyPart: '가슴',
              memo: '컨디션 좋음 #PR 시도 가능할듯',
              sets: [
                ExerciseSet(weight: 60, reps: 10, isCompleted: true),
                ExerciseSet(weight: 65, reps: 8, isCompleted: true),
                ExerciseSet(weight: 70, reps: 6, isCompleted: true),
              ],
            ),
            Exercise(
              name: 'Squat', // 영어 원본명
              bodyPart: '하체',
              memo: '무릎 상태 양호',
              sets: [
                ExerciseSet(weight: 80, reps: 12, isCompleted: true),
                ExerciseSet(weight: 85, reps: 10, isCompleted: true),
                ExerciseSet(weight: 90, reps: 8, isCompleted: true),
              ],
            ),
          ],
          isCompleted: true,
        ),
        
        // 5일 전 - 데드리프트, 랫풀다운
        Session(
          ymd: ymd(now.subtract(const Duration(days: 5))),
          exercises: [
            Exercise(
              name: 'Deadlift', // 영어 원본명
              bodyPart: '등',
              memo: '허리 조심 #주의',
              sets: [
                ExerciseSet(weight: 100, reps: 8, isCompleted: true),
                ExerciseSet(weight: 110, reps: 6, isCompleted: true),
                ExerciseSet(weight: 120, reps: 5, isCompleted: true),
              ],
            ),
            Exercise(
              name: 'Lat Pulldown', // 영어 원본명
              bodyPart: '등',
              sets: [
                ExerciseSet(weight: 45, reps: 12, isCompleted: true),
                ExerciseSet(weight: 50, reps: 10, isCompleted: true),
                ExerciseSet(weight: 55, reps: 8, isCompleted: true),
              ],
            ),
          ],
          isCompleted: true,
        ),
        
        // 3일 전 - 벤치프레스 (진전된 기록)
        Session(
          ymd: ymd(now.subtract(const Duration(days: 3))),
          exercises: [
            Exercise(
              name: 'Bench Press', // 영어 원본명
              bodyPart: '가슴',
              memo: '왼쪽 어깨 약간 불편 #통증',
              sets: [
                ExerciseSet(weight: 65, reps: 10, isCompleted: true),
                ExerciseSet(weight: 70, reps: 8, isCompleted: true),
                ExerciseSet(weight: 75, reps: 6, isCompleted: true),
                ExerciseSet(weight: 75, reps: 5, isCompleted: true),
              ],
            ),
            Exercise(
              name: 'Incline Dumbbell Press', // 영어 원본명
              bodyPart: '가슴',
              memo: '자극 좋음 #성공',
              sets: [
                ExerciseSet(weight: 25, reps: 12, isCompleted: true),
                ExerciseSet(weight: 30, reps: 10, isCompleted: true),
                ExerciseSet(weight: 32.5, reps: 8, isCompleted: true),
              ],
            ),
          ],
          isCompleted: true,
        ),
        
        // 1일 전 - 스쿼트 (진전된 기록)
        Session(
          ymd: ymd(now.subtract(const Duration(days: 1))),
          exercises: [
            Exercise(
              name: 'Squat', // 영어 원본명
              bodyPart: '하체',
              memo: '폼 개선됨 증량 준비 #진전',
              sets: [
                ExerciseSet(weight: 85, reps: 12, isCompleted: true),
                ExerciseSet(weight: 90, reps: 10, isCompleted: true),
                ExerciseSet(weight: 95, reps: 8, isCompleted: true),
                ExerciseSet(weight: 100, reps: 6, isCompleted: true),
              ],
            ),
            Exercise(
              name: 'Leg Press', // 영어 원본명
              bodyPart: '하체',
              sets: [
                ExerciseSet(weight: 150, reps: 15, isCompleted: true),
                ExerciseSet(weight: 170, reps: 12, isCompleted: true),
                ExerciseSet(weight: 180, reps: 10, isCompleted: true),
              ],
            ),
          ],
          isCompleted: true,
        ),
        
        // 10일 전 - 오래된 벤치프레스 기록
        Session(
          ymd: ymd(now.subtract(const Duration(days: 10))),
          exercises: [
            Exercise(
              name: 'Bench Press', // 영어 원본명
              bodyPart: '가슴',
              memo: '첫 시도 긴장됨',
              sets: [
                ExerciseSet(weight: 55, reps: 10, isCompleted: true),
                ExerciseSet(weight: 60, reps: 8, isCompleted: true),
                ExerciseSet(weight: 62.5, reps: 6, isCompleted: true),
              ],
            ),
          ],
          isCompleted: true,
        ),
      ];
      
      // 더미 데이터 저장
      for (final session in dummySessions) {
        await put(session);
      }
      
      print('✅ 더미 운동 데이터 생성 완료: ${dummySessions.length}개 세션 (영어 원본명)');
    } catch (e) {
      print('❌ 더미 데이터 생성 중 오류: $e');
    }
  }
}

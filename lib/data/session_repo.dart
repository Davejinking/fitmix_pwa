import 'package:flutter/foundation.dart';
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

  /// 운동 날짜와 휴식 날짜를 한 번에 조회 (최적화)
  Future<({Set<String> workoutDates, Set<String> restDates})> getAllSessionDates();
  
  /// 특정 운동의 최근 기록들을 조회 (최대 5개)
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5});
  
  /// 테스트용 더미 데이터 생성
  Future<void> seedDummyWorkoutData();
}

class HiveSessionRepo implements SessionRepo {
  static const boxName = 'sessions';
  static const indexBoxName = 'exercise_index';

  late Box<Session> _box;
  late Box _indexBox; // Key: Exercise Name, Value: List<String> (ymds)

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

    // 인덱스 박스 오픈
    if (Hive.isBoxOpen(indexBoxName)) {
      _indexBox = Hive.box(indexBoxName);
    } else {
      _indexBox = await Hive.openBox(indexBoxName);
    }

    // 인덱스 마이그레이션 (세션은 있는데 인덱스가 비어있는 경우)
    if (_indexBox.isEmpty && _box.isNotEmpty) {
      await _rebuildIndex();
    }
  }

  /// 인덱스 전체 재구축
  Future<void> _rebuildIndex() async {
    print('🔄 운동 기록 인덱스 재구축 중...');
    final tempIndex = <String, List<String>>{};

    for (final session in _box.values) {
      for (final exercise in session.exercises) {
        if (!tempIndex.containsKey(exercise.name)) {
          tempIndex[exercise.name] = [];
        }
        // 중복 방지
        if (!tempIndex[exercise.name]!.contains(session.ymd)) {
          tempIndex[exercise.name]!.add(session.ymd);
        }
      }
    }

    await _indexBox.putAll(tempIndex);
    print('✅ 인덱스 재구축 완료');
  }

  @override
  String ymd(DateTime d) => DateFormat(AppConstants.dateFormat).format(d);

  @override
  DateTime ymdToDateTime(String ymd) => DateFormat(AppConstants.dateFormat).parse(ymd);

  @override
  Future<Session?> get(String ymd) async => _box.get(ymd);

  @override
  Future<void> put(Session s) async {
    // 인덱스 업데이트
    final oldSession = _box.get(s.ymd);

    // 1. 이전 세션의 운동들을 인덱스에서 제거 (혹은 업데이트)
    // 간단하게 구현하기 위해: 일단 이전 세션의 운동들에서 해당 날짜 제거
    if (oldSession != null) {
      for (final exercise in oldSession.exercises) {
        await _removeFromIndex(exercise.name, s.ymd);
      }
    }

    // 2. 새로운 세션의 운동들을 인덱스에 추가
    for (final exercise in s.exercises) {
      await _addToIndex(exercise.name, s.ymd);
    }

    await _box.put(s.ymd, s);
  }

  @override
  Future<void> delete(String ymd) async {
    final session = await _box.get(ymd);
    if (session != null) {
      for (final exercise in session.exercises) {
        await _removeFromIndex(exercise.name, ymd);
      }
    }
    await _box.delete(ymd);
  }

  @override
  Future<void> clearAllData() async {
    await _box.clear();
    await _indexBox.clear();
  }

  /// 인덱스에 날짜 추가
  Future<void> _addToIndex(String exerciseName, String ymd) async {
    final List<String> currentList = (_indexBox.get(exerciseName) as List?)?.cast<String>() ?? [];
    if (!currentList.contains(ymd)) {
      currentList.add(ymd);
      // 날짜 순 정렬은 읽을 때 해도 됨. 하지만 저장할 때 해두면 읽기가 빠름.
      // 여기서는 추가만 하고, 읽을 때 정렬하거나, 아니면 내림차순 유지
      // 편의상 읽을 때 정렬한다고 가정 (데이터 양이 많지 않음)
      await _indexBox.put(exerciseName, currentList);
    }
  }

  /// 인덱스에서 날짜 제거
  Future<void> _removeFromIndex(String exerciseName, String ymd) async {
    final List<String> currentList = (_indexBox.get(exerciseName) as List?)?.cast<String>() ?? [];
    if (currentList.contains(ymd)) {
      currentList.remove(ymd);
      if (currentList.isEmpty) {
        await _indexBox.delete(exerciseName);
      } else {
        await _indexBox.put(exerciseName, currentList);
      }
    }
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
          debugPrint('⚠️ 세션 확인 중 오류: ${session.ymd}, $e');
          return false;
        }
      }).toList();
      // listAll()이 수행하던 정렬을 여기서 직접 수행
      workoutSessions.sort((a, b) => a.ymd.compareTo(b.ymd));
      return workoutSessions;
    } catch (e) {
      debugPrint('❌ 운동 세션 조회 중 오류: $e');
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
      debugPrint('❌ 운동 날짜 조회 중 오류: $e');
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
      debugPrint('❌ 휴식 날짜 조회 중 오류: $e');
      return {};
    }
  }

  @override
  Future<({Set<String> workoutDates, Set<String> restDates})> getAllSessionDates() async {
    try {
      final workoutDates = <String>{};
      final restDates = <String>{};

      for (final session in _box.values) {
        if (session.isWorkoutDay) {
          workoutDates.add(session.ymd);
        } else if (session.isRest) {
          restDates.add(session.ymd);
        }
      }
      return (workoutDates: workoutDates, restDates: restDates);
    } catch (e) {
      debugPrint('❌ 세션 날짜 전체 조회 중 오류: $e');
      return (workoutDates: <String>{}, restDates: <String>{});
    }
  }

  @override
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5}) async {
    try {
      final records = <ExerciseHistoryRecord>[];
      
      // 1. 검색할 운동 이름의 모든 별칭(다국어 등) 가져오기
      final searchAliases = _getAliases(exerciseName);

      // 2. 인덱스에서 해당 운동 이름들로 날짜 목록 조회 (중복 제거)
      final targetDates = <String>{};
      for (final name in searchAliases) {
        final dates = (_indexBox.get(name) as List?)?.cast<String>() ?? [];
        targetDates.addAll(dates);
      }

      // 3. 날짜 역순 정렬 (최신순)
      final sortedDates = targetDates.toList()
        ..sort((a, b) => b.compareTo(a));

      // 4. 인덱싱된 날짜에 대해서만 세션 조회
      for (final date in sortedDates) {
        if (records.length >= limit) break;

        final session = _box.get(date);
        if (session == null) continue;
        
        // 해당 운동이 있는지 확인 (다국어 매칭 지원)
        // Optimization: Use pre-calculated searchAliases directly instead of recalculating in _isExerciseNameMatch
        final matches = session.exercises.where((ex) => searchAliases.contains(ex.name));
        final exercise = matches.isEmpty ? null : matches.first;

        if (exercise != null && exercise.sets.isNotEmpty) {
          debugPrint('✅ 매칭된 운동 발견: ${exercise.name}, 세트 수: ${exercise.sets.length}');
          
          // 완료된 세트만 필터링
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          debugPrint('  - 완료된 세트 수: ${completedSets.length}');
          
          if (completedSets.isNotEmpty) {
            records.add(ExerciseHistoryRecord(
              date: session.ymd,
              sets: completedSets,
              memo: exercise.memo, // 메모 추가
            ));
            debugPrint('  - 기록 추가됨: ${session.ymd}, 메모: ${exercise.memo ?? "없음"}');
          }
        }
      }
      
      debugPrint('🔍 최종 기록 수: ${records.length}');
      return records;
    } catch (e) {
      debugPrint('❌ 운동 기록 조회 중 오류: $e');
      return [];
    }
  }

  /// 운동 이름 매칭 (다국어 지원)
  bool _isExerciseNameMatch(String storedName, String searchName) {
    if (storedName == searchName) return true;
    final aliases = _getAliases(searchName);
    return aliases.contains(storedName);
  }

  /// 운동 이름의 모든 별칭(원어 및 번역) 반환
  Set<String> _getAliases(String name) {
    const exerciseNameMap = {
      'Bench Press': ['벤치프레스', 'ベンチプレス'],
      'Squat': ['스쿼트', 'スクワット'],
      'Deadlift': ['데드리프트', 'デッドリフト'],
      'Lat Pulldown': ['랫풀다운', 'ラットプルダウン'],
      'Incline Dumbbell Press': ['인클라인 덤벨 프레스', 'インクライン・ダンベル・プレス'],
      'Leg Press': ['레그 프레스', 'レッグプレス'],
    };

    final aliases = <String>{name};

    // 1. name이 키(영어)인 경우
    if (exerciseNameMap.containsKey(name)) {
      aliases.addAll(exerciseNameMap[name]!);
    }

    // 2. name이 값(번역어) 중 하나인 경우 -> 키(영어)와 다른 번역어들 추가
    for (final entry in exerciseNameMap.entries) {
      if (entry.value.contains(name)) {
        aliases.add(entry.key); // 영어 추가
        aliases.addAll(entry.value); // 다른 번역어들 추가
      }
    }

    return aliases;
  }

  @override
  Future<void> seedDummyWorkoutData() async {
    try {
      final now = DateTime.now();
      
      // 지난 2주간의 더미 운동 데이터 생성 (영어 원본명 사용)
      final dummySessions = [
        // 7일 전 - 벤치프레스, 스쿼트
        Session(
          ymd: this.ymd(now.subtract(const Duration(days: 7))),
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
          ymd: this.ymd(now.subtract(const Duration(days: 5))),
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
          ymd: this.ymd(now.subtract(const Duration(days: 3))),
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
          ymd: this.ymd(now.subtract(const Duration(days: 1))),
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
          ymd: this.ymd(now.subtract(const Duration(days: 10))),
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
      await Future.wait(dummySessions.map((session) => put(session)));
      
      debugPrint('✅ 더미 운동 데이터 생성 완료: ${dummySessions.length}개 세션 (영어 원본명)');
    } catch (e) {
      debugPrint('❌ 더미 데이터 생성 중 오류: $e');
    }
  }
}

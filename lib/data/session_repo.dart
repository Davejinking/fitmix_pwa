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
  
  /// 테스트용 더미 데이터 생성
  Future<void> seedDummyWorkoutData();
}

class HiveSessionRepo implements SessionRepo {
  static const boxName = 'sessions';
  static const indexBoxName = 'exercise_index';

  late Box<Session> _box;
  late Box _indexBox;

  // 다국어 매칭 - ExerciseDB의 매핑을 활용
  // 영어 → 한국어/일본어 매칭
  static const _exerciseNameMap = {
    'Bench Press': ['벤치프레스', 'ベンチプレス'],
    'Squat': ['스쿼트', 'スクワット'],
    'Deadlift': ['데드리프트', 'デッドリフト'],
    'Lat Pulldown': ['랫풀다운', 'ラットプルダウン'],
    'Incline Dumbbell Press': ['인클라인 덤벨 프레스', 'インクライン・ダンベル・プレス'],
    'Leg Press': ['레그 프레스', 'レッグプレス'],
  };

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

    // 세션 박스 오픈
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

    // 마이그레이션: 세션은 있는데 인덱스가 비어있다면 인덱스 재구축
    if (_box.isNotEmpty && _indexBox.isEmpty) {
      print('⚡ [Performance] 인덱스 구축 시작...');
      await _rebuildIndex();
      print('✅ [Performance] 인덱스 구축 완료');
    }
  }

  /// 전체 세션을 순회하며 인덱스 생성
  Future<void> _rebuildIndex() async {
    // 인덱스 초기화
    await _indexBox.clear();

    // 모든 세션에 대해 인덱스 업데이트
    for (final session in _box.values) {
      await _updateIndexForSession(session);
    }
  }

  /// 특정 세션의 운동들을 인덱스에 추가
  Future<void> _updateIndexForSession(Session session) async {
    if (!session.hasExercises) return;

    for (final exercise in session.exercises) {
      final name = exercise.name;
      final List<String> dates = (_indexBox.get(name) ?? []).cast<String>().toList();

      if (!dates.contains(session.ymd)) {
        dates.add(session.ymd);
        await _indexBox.put(name, dates);
      }
    }
  }

  /// 인덱스에서 특정 세션의 날짜 제거
  Future<void> _removeFromIndex(Session session) async {
    for (final exercise in session.exercises) {
      final name = exercise.name;
      final List<String> dates = (_indexBox.get(name) ?? []).cast<String>().toList();

      if (dates.remove(session.ymd)) {
        if (dates.isEmpty) {
          await _indexBox.delete(name);
        } else {
          await _indexBox.put(name, dates);
        }
      }
    }
  }

  @override
  String ymd(DateTime d) => DateFormat(AppConstants.dateFormat).format(d);

  @override
  DateTime ymdToDateTime(String ymd) => DateFormat(AppConstants.dateFormat).parse(ymd);

  @override
  Future<Session?> get(String ymd) async => _box.get(ymd);

  @override
  Future<void> put(Session s) async {
    // 인덱스 업데이트 (추가만 수행, 제시는 Lazy Cleanup)
    await _updateIndexForSession(s);
    await _box.put(s.ymd, s);
  }

  @override
  Future<void> delete(String ymd) async {
    final session = _box.get(ymd);
    if (session != null) {
      await _removeFromIndex(session);
    }
    await _box.delete(ymd);
  }

  @override
  Future<void> clearAllData() async {
    await _indexBox.clear();
    await _box.clear();
  }

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
      if (rest) {
        // 운동 제거 전 인덱스 정리
        await _removeFromIndex(existing);
        existing.exercises.clear();
      }
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

  /// 운동 이름 확장 (동의어 포함)
  Set<String> _expandSynonyms(String searchName) {
    final names = <String>{searchName};

    // 1. searchName이 Key(영어)인 경우 Value(번역) 추가
    if (_exerciseNameMap.containsKey(searchName)) {
      names.addAll(_exerciseNameMap[searchName]!);
    }

    // 2. searchName이 Value(번역)에 포함된 경우 Key(영어) 및 다른 번역 추가
    for (final entry in _exerciseNameMap.entries) {
      if (entry.value.contains(searchName)) {
        names.add(entry.key); // 영어 이름 추가
        names.addAll(entry.value); // 다른 번역 이름들 추가
      }
    }

    return names;
  }

  /// 인덱스에서 잘못된 참조 제거 (Self-Repairing)
  Future<void> _repairIndex(String exerciseName, String date) async {
    // print('🔧 인덱스 복구: $exerciseName @ $date 제거');
    final dates = (_indexBox.get(exerciseName) ?? []).cast<String>().toList();
    if (dates.remove(date)) {
        await _indexBox.put(exerciseName, dates);
    }
  }

  @override
  Future<List<ExerciseHistoryRecord>> getRecentExerciseHistory(String exerciseName, {int limit = 5}) async {
    try {
      print('🔍 getRecentExerciseHistory 호출됨 (Indexed)');
      print('🔍 검색할 운동명: "$exerciseName"');
      
      // 1. 검색어 확장 (동의어 포함)
      final searchNames = _expandSynonyms(exerciseName);
      
      // 2. 인덱스 조회
      final allDates = <String>{};
      for (final name in searchNames) {
        final dates = (_indexBox.get(name) ?? []).cast<String>();
        allDates.addAll(dates);
      }
      
      print('🔍 인덱스 검색 결과: ${allDates.length}개의 날짜 발견');

      // 3. 날짜 역순 정렬 (최신순)
      final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));

      final records = <ExerciseHistoryRecord>[];
      
      // 4. 세션 조회 및 필터링
      for (final date in sortedDates) {
        if (records.length >= limit) break;
        
        final session = _box.get(date);
        if (session == null) {
           // 세션이 없으면 인덱스 정리
           for (final name in searchNames) {
             await _repairIndex(name, date);
           }
           continue;
        }

        // 해당 운동 찾기
        // 주의: 인덱스는 운동이 있다고 했지만, 실제 세션에는 없을 수 있음 (삭제/수정된 경우)
        // 이 경우 Self-Repairing 메커니즘 동작

        // 검색어 집합(searchNames)에 포함된 운동 찾기
        // 또는 기존 로직대로 _isExerciseNameMatch 사용 가능하지만,
        // 이미 searchNames를 확장했으므로 이름이 포함되어 있는지 확인하면 됨.
        final matches = session.exercises.where((ex) => searchNames.contains(ex.name) || _isExerciseNameMatch(ex.name, exerciseName));
        final exercise = matches.isEmpty ? null : matches.first;

        if (exercise != null && exercise.sets.isNotEmpty) {
          // 완료된 세트만 필터링
          final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
          
          if (completedSets.isNotEmpty) {
            records.add(ExerciseHistoryRecord(
              date: session.ymd,
              sets: completedSets,
              memo: exercise.memo,
            ));
          }
        } else {
          // 인덱스에는 있었지만 실제로는 없는 경우 (False Positive) -> 인덱스 정리
          // 정확히 어떤 이름으로 인덱싱 되었는지 모르므로, searchNames에 있는 후보들에서 해당 날짜 제거 시도
          for (final name in searchNames) {
             // 현재 세션에 이 이름의 운동이 없다면 인덱스에서 제거
             if (!session.exercises.any((e) => e.name == name)) {
                await _repairIndex(name, date);
             }
          }
        }
      }
      
      print('🔍 최종 기록 수: ${records.length}');
      return records;
    } catch (e, stack) {
      print('❌ 운동 기록 조회 중 오류: $e');
      print(stack);
      return [];
    }
  }

  /// 운동 이름 매칭 (다국어 지원) - 기존 호환성 유지용
  bool _isExerciseNameMatch(String storedName, String searchName) {
    if (storedName == searchName) return true;
    
    if (_exerciseNameMap.containsKey(storedName)) {
      return _exerciseNameMap[storedName]!.contains(searchName);
    }
    
    if (_exerciseNameMap.containsKey(searchName)) {
      return _exerciseNameMap[searchName]!.contains(storedName);
    }
    
    for (final entry in _exerciseNameMap.entries) {
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

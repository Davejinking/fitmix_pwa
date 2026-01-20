import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  late HiveSessionRepo repo;
  late Directory tempDir;

  setUp(() async {
    // Initialize Hive for testing
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

    repo = HiveSessionRepo();
    await repo.init();
    await repo.clearAllData();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    try {
        tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('QA Session 11 - T21 & T22', () {
    test('T21: 날짜 경계(00:00) - 날짜별 세션 분리 저장 검증', () async {
      // Arrange
      final date1 = '2025-01-01'; // 23:59 상황 가정
      final date2 = '2025-01-02'; // 00:01 상황 가정

      final session1 = Session(ymd: date1, exercises: [], isRest: false);
      final session2 = Session(ymd: date2, exercises: [], isRest: false);

      // Act
      await repo.put(session1);
      await repo.put(session2);

      // Assert
      final fetched1 = await repo.get(date1);
      final fetched2 = await repo.get(date2);

      expect(fetched1, isNotNull);
      expect(fetched1!.ymd, date1);

      expect(fetched2, isNotNull);
      expect(fetched2!.ymd, date2);

      // 두 세션이 서로 다른 객체이고 키가 다름을 확인
      expect(fetched1.ymd, isNot(equals(fetched2.ymd)));
    });

    test('T22: 최신순 정렬 - listAll(오름차순) vs RecentHistory(내림차순) 검증', () async {
      // Arrange
      final date1 = '2025-01-01';
      final date2 = '2025-01-02';
      final date3 = '2025-01-03';

      final exerciseName = 'TestPushUp';
      final exercise = Exercise(
        name: exerciseName,
        bodyPart: 'Chest',
        sets: [ExerciseSet(weight: 10, reps: 10, isCompleted: true)]
      );

      final s1 = Session(ymd: date1, exercises: [exercise], isRest: false); // 가장 과거
      final s3 = Session(ymd: date3, exercises: [exercise], isRest: false); // 가장 최신
      final s2 = Session(ymd: date2, exercises: [exercise], isRest: false); // 중간

      // Act: 순서 섞어서 저장
      await repo.put(s3);
      await repo.put(s1);
      await repo.put(s2);

      // Assert 1: listAll()은 오름차순(과거 -> 최신) 정렬됨을 확인
      // (CalendarPage의 날짜 계산 등에 사용됨)
      final allSessions = await repo.listAll();
      expect(allSessions.length, 3);
      expect(allSessions[0].ymd, date1);
      expect(allSessions[1].ymd, date2);
      expect(allSessions[2].ymd, date3);

      // Assert 2: Recent History는 내림차순(최신 -> 과거) 정렬됨을 확인
      // (T22 "최신 날짜가 상단에 위치" 기대 결과에 부합하는 로직)
      final history = await repo.getRecentExerciseHistory(exerciseName);
      expect(history.length, 3);
      expect(history[0].date, date3); // 최신이 0번 인덱스(상단)
      expect(history[1].date, date2);
      expect(history[2].date, date1); // 과거가 마지막(하단)
    });
  });
}

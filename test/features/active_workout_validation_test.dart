import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late Session testSession;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();

    // 기본 세션 데이터 설정
    testSession = Session(
      ymd: '2023-10-25',
      exercises: [
        Exercise(
          name: 'Bench Press',
          bodyPart: 'Chest',
          sets: [
            ExerciseSet(weight: 60, reps: 10, isCompleted: true),
          ],
        ),
      ],
    );

    registerFallbackValue(testSession);
    when(() => mockSessionRepo.put(any())).thenAnswer((_) async {});
  });

  Widget createSubject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'), // 한국어 강제
      home: ActiveWorkoutPage(
        session: testSession,
        repo: mockSessionRepo,
        exerciseRepo: mockExerciseRepo,
        date: DateTime(2023, 10, 25),
      ),
    );
  }

  testWidgets('T02: 0 reps 입력 시 저장이 차단되고 에러 스낵바가 표시된다', (tester) async {
    // Given
    testSession.exercises.first.sets.first.reps = 0;

    await tester.pumpWidget(createSubject());

    // When: 종료 버튼 클릭
    final stopButton = find.byIcon(Icons.stop_circle_outlined);
    await tester.tap(stopButton);
    await tester.pump();

    // Then: 저장 메소드 호출 안됨
    verifyNever(() => mockSessionRepo.put(any()));

    // Then: 에러 스낵바 표시
    expect(find.text('0회 반복은 저장할 수 없습니다.'), findsOneWidget);
  });

  testWidgets('T01: 0 kg 입력 시 저장이 차단되고 에러 스낵바가 표시된다', (tester) async {
    // Given
    testSession.exercises.first.sets.first.weight = 0;

    await tester.pumpWidget(createSubject());

    // When
    final stopButton = find.byIcon(Icons.stop_circle_outlined);
    await tester.tap(stopButton);
    await tester.pump();

    // Then
    verifyNever(() => mockSessionRepo.put(any()));
    expect(find.textContaining('0kg 무게는 저장할 수 없습니다'), findsOneWidget);
  });

  testWidgets('T11: 저장 버튼 연타 시 중복 저장이 방지된다', (tester) async {
    // Given
    testSession.exercises.first.sets.first.weight = 100;
    testSession.exercises.first.sets.first.reps = 10;
    testSession.exercises.first.sets.first.isCompleted = true;

    // 저장 1초 지연
    when(() => mockSessionRepo.put(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
    });

    await tester.pumpWidget(createSubject());

    // When: 종료 버튼 -> 다이얼로그 팝업
    final stopButton = find.byIcon(Icons.stop_circle_outlined);
    await tester.tap(stopButton);
    await tester.pumpAndSettle();

    // 다이얼로그의 완료(저장) 버튼 찾기
    final confirmButton = find.byType(ElevatedButton);
    expect(confirmButton, findsOneWidget);

    // 연타
    await tester.tap(confirmButton);
    await tester.tap(confirmButton);
    await tester.tap(confirmButton);

    // 비동기 처리 대기 (저장 완료까지)
    await tester.pump(const Duration(milliseconds: 1100));

    // Then: 호출 1회 확인
    verify(() => mockSessionRepo.put(any())).called(1);
  });
}

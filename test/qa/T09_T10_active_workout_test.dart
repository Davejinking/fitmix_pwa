import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([MockSpec<SessionRepo>(), MockSpec<ExerciseLibraryRepo>()])
import 'T09_T10_active_workout_test.mocks.dart';

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late Session session;

  setUp(() async {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();

    SharedPreferences.setMockInitialValues({});

    session = Session(
      ymd: '2023-01-01',
      exercises: [
        Exercise(
          name: 'Bench Press',
          bodyPart: 'Chest',
          sets: [
            ExerciseSet(weight: 100, reps: 10),
          ],
        ),
      ],
    );
  });

  Widget createSubject() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko')],
      home: ActiveWorkoutPage(
        session: session,
        repo: mockSessionRepo,
        exerciseRepo: mockExerciseRepo,
        date: DateTime(2023, 1, 1),
      ),
    );
  }

  group('T09: Background Return Maintenance', () {
    testWidgets('앱이 백그라운드로 갔다가 돌아와도 입력값과 상태가 유지되어야 한다', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('벤치프레스'), findsOneWidget, reason: "운동 이름이 표시되어야 함 (한글 변환됨)");

      final checkboxFinder = find.byType(Checkbox).first;
      await tester.tap(checkboxFinder);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkboxFinder).value, true);

      // 백그라운드 전환 시뮬레이션
      // Correct sequence for Flutter > 3.13:
      // resumed -> inactive -> hidden -> paused
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // 포그라운드 복귀 시뮬레이션
      // paused -> hidden -> inactive -> resumed
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      // 상태 유지 확인
      expect(find.text('벤치프레스'), findsOneWidget);
      expect(tester.widget<Checkbox>(checkboxFinder).value, true);
    });
  });

  group('T10: Race Condition during Screen Transition', () {
    testWidgets('운동 완료 저장 중 뒤로가기나 다른 동작 시 중복 저장이 발생하지 않아야 한다', (tester) async {
      int putCallCount = 0;
      when(mockSessionRepo.put(any)).thenAnswer((_) async {
        putCallCount++;
        // 저장 딜레이
        await Future.delayed(const Duration(milliseconds: 500));
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final finishButtonFinder = find.byIcon(Icons.stop_circle_outlined);
      expect(finishButtonFinder, findsOneWidget);

      await tester.tap(finishButtonFinder);
      await tester.pumpAndSettle();

      // 다이얼로그 확인 버튼 클릭
      final dialogConfirmButton = find.byType(ElevatedButton).last;
      await tester.tap(dialogConfirmButton);

      // 다이얼로그 닫히고 저장이 시작됨 (500ms 딜레이 중)
      await tester.pump(const Duration(milliseconds: 100));

      // 뒤로가기 시도
      final dynamic widgetsBinding = tester.binding;
      widgetsBinding.handlePopRoute();

      // 뒤로가기 처리가 실행될 시간 부여
      await tester.pump(const Duration(milliseconds: 100));

      // 모든 작업 완료
      await tester.pumpAndSettle();

      // 검증: 중복 저장이 발생했는지 확인
      expect(putCallCount, 1, reason: "중복 저장이 발생하지 않아야 함");
    });
  });
}

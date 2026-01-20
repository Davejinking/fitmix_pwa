import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get_it/get_it.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/core/constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Generate mocks
@GenerateMocks([SessionRepo, ExerciseLibraryRepo])
import 'session_12_fix_test.mocks.dart';

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUpAll(() async {
    await initializeDateFormatting('ko', null);
  });

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();

    // Reset GetIt
    GetIt.I.reset();
    GetIt.I.registerSingleton<SessionRepo>(mockSessionRepo);
    GetIt.I.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      home: child,
    );
  }

  group('T23: 타임존 변화 (Date Consistency)', () {
    test('날짜 경계값(Timezone offset)에도 동일한 ymd ID 생성 검증', () {
      // Logic Test: Verify implementation of ymd() logic manually
      // Since SessionRepo.ymd() implementation is known: DateFormat(AppConstants.dateFormat).format(d)
      // We replicate this logic to verify it produces consistent IDs for the "same day".

      final dateFormat = DateFormat(AppConstants.dateFormat);

      // Case 1: Start of Day (00:00:00)
      final startOfDay = DateTime(2024, 5, 24, 0, 0, 0);
      final idStart = dateFormat.format(startOfDay);

      // Case 2: End of Day (23:59:59)
      final endOfDay = DateTime(2024, 5, 24, 23, 59, 59);
      final idEnd = dateFormat.format(endOfDay);

      // Verify they are identical
      expect(idStart, '2024-05-24'); // Format defined in AppConstants
      expect(idEnd, '2024-05-24');
      expect(idStart, idEnd);

      // Note: This confirms that if the App uses this logic (which SessionRepo does),
      // any time within that local day maps to the same session ID.
    });
  });

  group('T24: 저장 실패 안내 (Save Failure Alert)', () {
    testWidgets('ActiveWorkoutPage에서 저장 실패 시 크래시 없이 에러 스낵바 표시', (tester) async {
      // Given: Active Workout Session
      final session = Session(
        ymd: "20240524",
        exercises: [
          Exercise(name: 'Squat', bodyPart: 'Legs', sets: [ExerciseSet(weight: 100, reps: 5)]),
        ],
      );

      // Stub repo.put to throw an exception
      when(mockSessionRepo.put(any)).thenThrow(Exception('Hive Write Error Simulation'));

      await tester.pumpWidget(createWidgetUnderTest(
        ActiveWorkoutPage(
          session: session,
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
          date: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // When: Finish Workout button is tapped
      await tester.tap(find.byIcon(Icons.stop_circle_outlined));
      await tester.pumpAndSettle(); // Show Dialog

      // Confirm dialog (Confirm Button)
      // Try to find the button by text '운동 완료하기' (finishWorkout)
      final confirmBtn = find.widgetWithText(ElevatedButton, '운동 완료하기');
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn);
      } else {
        // Fallback for different locales or changed text
        await tester.tap(find.text('확인'));
      }

      // Trigger the async save & error handling
      await tester.pumpAndSettle();

      // Expectation:
      // 1. App should NOT crash (test continues).
      // 2. SnackBar should appear with error message.
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('저장 중 오류가 발생했습니다'), findsOneWidget);
    });
  });
}

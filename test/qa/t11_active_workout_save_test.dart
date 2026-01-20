import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/models/user_profile.dart'; // Needed for UserRepo if used?

@GenerateMocks([SessionRepo, ExerciseLibraryRepo])
import 't11_active_workout_save_test.mocks.dart';

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late Session testSession;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
    testSession = Session(
      ymd: '2025-05-20',
      exercises: [
        Exercise(
          name: 'Bench Press',
          bodyPart: 'Chest',
          sets: [ExerciseSet(weight: 100, reps: 10, isCompleted: true)],
        ),
      ],
    );
  });

  testWidgets('T11: Save/Finish button double-tap prevents duplicate saves', (WidgetTester tester) async {
    // Arrange
    // when(mockSessionRepo.put(any)).thenAnswer((_) async => Future.value());
    // Simulate a slow save operation to allow time for double tap
    var saveCallCount = 0;
    final saveCompleter = Completer<void>();

    when(mockSessionRepo.put(any)).thenAnswer((_) async {
      saveCallCount++;
      await saveCompleter.future; // Block until we manually complete it
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('en')],
        locale: const Locale('ko'),
        home: ActiveWorkoutPage(
          session: testSession,
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
          date: DateTime(2025, 5, 20),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act
    // 1. Find the Finish button (Stop icon) in the bottom bar
    final finishButton = find.byIcon(Icons.stop_circle_outlined);
    expect(finishButton, findsOneWidget);

    // 2. Tap it to open the dialog
    await tester.tap(finishButton);
    await tester.pumpAndSettle(); // Dialog animation

    // 3. Find "운동 완료하기" or "확인" button in the dialog
    // The dialog has "운동 완료하기" (finishWorkout) or "확인" (confirm)
    // In Korean: "운동 완료하기" or "확인"
    // Let's try finding the ElevatedButton in the dialog.
    final confirmButton = find.widgetWithText(ElevatedButton, '운동 완료하기');
    expect(confirmButton, findsOneWidget);

    // 4. Tap the confirm button MULTIPLE times quickly
    await tester.tap(confirmButton);
    await tester.pump(); // Start the first tap processing
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.tap(confirmButton);
    await tester.pump();

    // 5. Complete the save operation
    saveCompleter.complete();
    await tester.pumpAndSettle(); // Allow async operations to finish

    // Assert
    // Verify that put() was called exactly ONCE despite multiple taps
    verify(mockSessionRepo.put(any)).called(1);
    expect(saveCallCount, 1, reason: "SessionRepo.put should be called exactly once.");
  });
}

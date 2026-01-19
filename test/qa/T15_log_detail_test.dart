import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fitmix_pwa/pages/log_detail_page.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

// Generate Mock classes
@GenerateNiceMocks([
  MockSpec<SessionRepo>(),
  MockSpec<ExerciseLibraryRepo>(),
])
import 'T15_log_detail_test.mocks.dart';

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  testWidgets('T15: LogDetailPage should render correctly with completed session data',
      (WidgetTester tester) async {
    // 1. Arrange
    final testDate = DateTime(2025, 5, 23);
    final exerciseSet1 = ExerciseSet(weight: 100.0, reps: 5);
    final exerciseSet2 = ExerciseSet(weight: 105.0, reps: 3);

    // Create a completed session with exercises
    final session = Session(
      ymd: '20250523',
      exercises: [
        Exercise(
          name: 'Bench Press',
          bodyPart: 'Chest',
          sets: [exerciseSet1, exerciseSet2],
        ),
        Exercise(
          name: 'Squat',
          bodyPart: 'Legs',
          sets: [ExerciseSet(weight: 140.0, reps: 5)],
        ),
      ],
      // startTime/endTime are not in Session model, removed.
      isCompleted: true,
    );

    // Mock behavior
    when(mockSessionRepo.ymdToDateTime('20250523')).thenReturn(testDate);

    // 2. Act
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
        ],
        home: LogDetailPage(
          session: session,
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 3. Assert - Check Basic Rendering
    expect(find.text('WORKOUT LOG'), findsOneWidget);
    expect(find.text('[COMPLETE]'), findsOneWidget); // Status badge

    // Check Date rendering (Format: YYYY.MM.DD)
    expect(find.text('2025.05.23'), findsOneWidget);

    // Check Exercises are listed
    expect(find.text('BENCH PRESS'), findsOneWidget);
    expect(find.text('SQUAT'), findsOneWidget);

    // Check Stats (Summary Strip)
    // 3 sets total (2 bench + 1 squat)
    expect(find.text('3'), findsOneWidget); // Total Sets display

    // Verify Expand functionality
    final benchPressFinder = find.text('BENCH PRESS');
    await tester.tap(benchPressFinder);
    await tester.pumpAndSettle();

    // Check expanded details
    expect(find.text('100.0kg'), findsOneWidget);
    expect(find.text('105.0kg'), findsOneWidget);
    expect(find.text('140.0kg'), findsNothing); // Should be under Squat, not visible yet? Actually Squat is separate tile.
  });
}

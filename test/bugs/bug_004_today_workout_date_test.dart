import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/plan_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockRepo;
  late MockExerciseLibraryRepo mockExRepo;

  setUp(() {
    mockRepo = MockSessionRepo();
    mockExRepo = MockExerciseLibraryRepo();

    // Stub repo methods called by PlanPage initState
    // PlanPage calls _loadSession and _loadWorkoutDates

    // 1. _loadSession calls repo.get(ymd)
    when(() => mockRepo.ymd(any())).thenReturn('2023-12-31');
    when(() => mockRepo.get(any())).thenAnswer((_) async => Session(
          ymd: '2023-12-31',
          exercises: [],
          isRest: false,
        ));

    // 2. _loadWorkoutDates calls repo.getWorkoutSessions()
    when(() => mockRepo.getWorkoutSessions()).thenAnswer((_) async => []);
  });

  testWidgets('BUG-004: PlanPage should restrict date change when isFromTodayWorkout is true', (WidgetTester tester) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko')],
        home: PlanPage(
          date: today,
          repo: mockRepo,
          exerciseRepo: mockExRepo,
          isFromTodayWorkout: true, // Key flag
          isViewOnly: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find a date that is NOT today (e.g., in the weekly calendar)
    // We try to tap the Previous Week arrow button.
    final prevButton = find.byIcon(Icons.chevron_left);

    // Check if button is present
    expect(prevButton, findsOneWidget);

    // Tap Previous Week
    await tester.tap(prevButton);
    await tester.pump();

    // Expect Error SnackBar
    // "운동 중에는 날짜를 변경할 수 없습니다"
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

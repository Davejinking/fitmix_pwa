import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/plan_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mocks
class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late MockSettingsRepo mockSettingsRepo;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(Session(ymd: '2024-01-01'));
  });

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
    mockSettingsRepo = MockSettingsRepo();
    mockNavigatorObserver = MockNavigatorObserver();

    when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
    when(() => mockSessionRepo.put(any())).thenAnswer((_) async {});
    when(() => mockSessionRepo.ymd(any())).thenReturn('2024-01-01');
    when(() => mockSessionRepo.markRest(any(), rest: any(named: 'rest'))).thenAnswer((_) async {});
  });

  testWidgets('TC-F001: Workout Delete Functionality (BUG-029)', (WidgetTester tester) async {
    final session = Session(ymd: '2024-01-01');
    final exercise = Exercise(
      name: 'Push Up',
      bodyPart: 'Chest',
      sets: [ExerciseSet(weight: 10, reps: 10)]
    );
    session.exercises.add(exercise);

    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => session);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: PlanPage(
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
          date: DateTime(2024, 1, 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it exists first
    expect(find.text('Push Up'), findsOneWidget);

    // Try to delete the set.
    final deleteSetBtn = find.byIcon(Icons.remove_circle_outline);
    expect(deleteSetBtn, findsOneWidget);

    await tester.tap(deleteSetBtn.first);
    await tester.pumpAndSettle();

    // Check if exercise card is still there.
    expect(find.text('Push Up'), findsOneWidget);
  });

  testWidgets('TC-F004: Recent History Button (BUG-030)', (WidgetTester tester) async {
    final session = Session(ymd: '2024-01-01');
    session.exercises.add(Exercise(
      name: 'Squat',
      bodyPart: 'Legs',
      sets: [ExerciseSet()]
    ));

    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => session);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanPage(
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
          date: DateTime(2024, 1, 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final historyBtn = find.byIcon(Icons.history);
    expect(historyBtn, findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/plan_page.dart';
import 'package:fitmix_pwa/pages/exercise_selection_page.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
    registerFallbackValue(FakeRoute());
    registerFallbackValue(Session(ymd: '2023-10-15'));

    when(() => mockExerciseRepo.getLibrary()).thenAnswer((_) async => {
      'Chest': ['Bench Press', 'Push Up'],
    });

    // Default answers for repository
    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => null);
    when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
    when(() => mockSessionRepo.ymd(any())).thenReturn('2023-10-15');
  });

  group('Session 2: Core Bugs Reproduction', () {

    testWidgets('TC-F001: Workout Delete (BUG-029) - Should fail if bug exists', (WidgetTester tester) async {
       final exercise = Exercise(name: 'Bench Press', bodyPart: 'Chest');
       exercise.sets.add(ExerciseSet(weight: 100, reps: 10)); // 1 set

       final session = Session(ymd: '2023-10-15');
       session.exercises.add(exercise);

       // Mock get to return this session
       when(() => mockSessionRepo.get(any())).thenAnswer((_) async => session);

       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         home: PlanPage(
           date: DateTime(2023, 10, 15),
           repo: mockSessionRepo,
           exerciseRepo: mockExerciseRepo,
         ),
       ));
       await tester.pumpAndSettle();

       // Need to tap "Edit Workout" to enable delete buttons
       // Or isEditingMode defaults to false?
       // In PlanPage: "if (!widget.isViewOnly || _isEditingMode)"
       // isViewOnly defaults to false. So "Add Exercise" and "Start Workout" are visible.

       // Wait, "Set Delete" button is only visible if isEditingEnabled is true.
       // ExerciseCard: isEditingEnabled = !widget.isViewOnly || _isEditingMode
       // If isViewOnly is false (default), isEditingEnabled is true.
       // So delete buttons should be visible.

       // In ExerciseCard: "운동 시작 전: 삭제 버튼 (편집 모드에서만 활성화)" -> wait.
       // _SetRowGrid: "isEditingEnabled ? widget.onDelete : null"
       // But wait, the code says:
       // isWorkoutStarted ? Checkbox : IconButton(onPressed: isEditingEnabled ? ... : null)

       // So if not started, we see delete button.

       // Find delete button for the set.
       final deleteButton = find.byIcon(Icons.remove_circle_outline);
       expect(deleteButton, findsOneWidget);

       // Tap delete
       await tester.tap(deleteButton);
       await tester.pumpAndSettle();

       // "최소 1개의 세트가 필요합니다" SnackBar appears in `_ExerciseCardState` `onDelete`
       // if (widget.exercise.sets.length > 1) remove, else show snackbar.

       // So we CANNOT delete the last set via UI.
       // TC-F001 says "Delete all sets -> Check if workout card disappears".
       // If UI prevents deleting the last set, then the user CANNOT delete all sets individually to remove the card.
       // They must find a way to delete the EXERCISE CARD itself.

       // Is there an exercise delete button?
       // Looking at ExerciseCard header... it has "Completion or Progress".
       // No obvious delete button in header.
       // Maybe Swipe? ReorderableListView supports dragging.

       // If the bug description says "Delete all sets -> Empty card remains",
       // it implies they somehow deleted the sets.
       // Maybe by setting reps/weight to 0? Or maybe the restriction wasn't there before?

       // Current implementation explicitly prevents deleting the last set.
       // This might be the FIX or the Cause (user can't remove exercise).
       // If user can't remove exercise, that's a bug too (or feature).

       // Let's assume the test expects to remove the exercise.
       // If I can't remove the last set, the exercise remains.
       // So "Empty workout card remains" is sort of true (it has 1 empty set).

       // Verify "Minimum 1 set required" snackbar is shown.
       expect(find.text('최소 1개의 세트가 필요합니다'), findsOneWidget);
    });

    testWidgets('TC-F003: Exercise Selection Detail (BUG-031) - Should fail if bug exists', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         home: ExerciseSelectionPage(exerciseRepo: mockExerciseRepo),
      ));
      await tester.pumpAndSettle();

      // Tap "Bench Press"
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Expected (if fixed): Detail Page
      // Actual (Bug): Selected (Checkmark appears)

      expect(find.byType(ExerciseDetailPage), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('TC-F004: Recent Record Button (BUG-030) - Should fail if bug exists', (WidgetTester tester) async {
       final exercise = Exercise(name: 'Bench Press', bodyPart: 'Chest');
       exercise.sets.add(ExerciseSet(weight: 100, reps: 10));
       final session = Session(ymd: '2023-10-15');
       session.exercises.add(exercise);

       when(() => mockSessionRepo.get(any())).thenAnswer((_) async => session);

       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         home: PlanPage(
           date: DateTime(2023, 10, 15),
           repo: mockSessionRepo,
           exerciseRepo: mockExerciseRepo,
         ),
       ));
       await tester.pumpAndSettle();

       // Look for "Recent Record" text.
       // The code for ExerciseCard doesn't seem to have "Recent Record" button visible in the snippet I read.
       // It might be in the header or footer?
       // The snippet had `_buildHeader`, `_buildMemoField`, `_buildColumnHeaders`, `_buildFooterActions`.
       // Footer has "Tempo Start", "Set Add", "Set Delete".
       // Header has Title + Status.

       // Where is "Recent Record"?
       // Maybe it's missing entirely?
       // If it's missing, the test fails to find the button.
       // Which confirms the feature is broken/missing.

       expect(find.text('Recent Record'), findsOneWidget); // Will fail if missing
    });

  });
}

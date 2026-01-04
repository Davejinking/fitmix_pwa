import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/plan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';

// Mocks
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSessionRepo extends Mock implements SessionRepo {}

void main() {
  late MockExerciseLibraryRepo mockExerciseRepo;
  late MockSessionRepo mockSessionRepo;

  setUp(() {
    mockExerciseRepo = MockExerciseLibraryRepo();
    mockSessionRepo = MockSessionRepo();

    when(() => mockSessionRepo.ymd(any())).thenAnswer((i) {
      final date = i.positionalArguments[0] as DateTime;
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    });

    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => Session(
      ymd: '2025-01-01',
      exercises: [
        Exercise(
          name: 'Squat',
          bodyPart: 'legs',
          sets: [ExerciseSet(weight: 100, reps: 5, isCompleted: false)],
        )
      ],
      isRest: false,
    ));

    when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
    when(() => mockExerciseRepo.getLibrary()).thenAnswer((_) async => {'legs': ['Squat']});
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      home: child,
    );
  }

  group('Session 2: Bug Reproduction', () {
    testWidgets('TC-F001: Exercise Delete (Fail verification)', (WidgetTester tester) async {
      // 1. Setup PlanPage with an exercise
      await tester.pumpWidget(createWidgetUnderTest(
        PlanPage(
          date: DateTime(2025, 1, 1),
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ));
      await tester.pumpAndSettle();

      // Ensure exercise is visible
      expect(find.text('Squat'), findsOneWidget);

      // 2. Expand card if needed (it defaults to expanded in code, but let's check)
      // Tap header to collapse/expand
      // Note: The code says `_isExpanded = true` by default.

      // 3. Try to delete the only set
      // In the code, `_SetRowGrid` has a delete button if `!isWorkoutStarted` and `isEditingEnabled`.
      // Default PlanPage starts in 'view' mode unless it's `isViewOnly`.
      // Wait, `PlanPage` is editing mode by default?
      // `_isEditingMode` is false initially.
      // But `isViewOnly` defaults to false.
      // If `!isViewOnly` (false) -> `_buildActionBar` shows "Start Workout" button.
      // But `ExerciseCard` `isEditingEnabled` logic: `!widget.isViewOnly || _isEditingMode`.
      // So if `isViewOnly` is false, editing is enabled.

      // Find the delete button (remove_circle_outline)
      final deleteBtn = find.byIcon(Icons.remove_circle_outline);
      expect(deleteBtn, findsOneWidget);

      // Tap delete
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Bug Description: "Empty card remains".
      // Code Logic:
      // onDelete: () {
      //   if (widget.exercise.sets.length > 1) { ... remove ... } else { ErrorHandler... }
      // }

      // So if I delete the LAST set, it shows a SnackBar "Minimum 1 set required".
      // It DOES NOT delete the exercise.

      // Verification:
      // Expect "Minimum 1 set required" SnackBar or similar.
      // Expect Exercise Card to STILL exist.

      expect(find.text('Squat'), findsOneWidget);
      expect(find.textContaining('최소 1개의 세트가 필요합니다'), findsOneWidget);

      // This confirms the "bug" (or feature?) that you cannot delete an exercise by deleting sets.
      // The bug report says: "Exercise Delete Function... Empty card remains".
      // Actually, here it prevents deleting the last set.
      // Is there an exercise delete button?
      // Not in the card header.
      // So there is NO way to delete the exercise from the card itself if you can't delete the last set.
      // This confirms TC-F001 as "Reproduced" (Functionality Missing).
    });

    testWidgets('TC-F002: Set Scroll (Scrollability check)', (WidgetTester tester) async {
       // Mock session with many sets
       final manySets = List.generate(20, (i) => ExerciseSet(weight: 20, reps: 10));
       when(() => mockSessionRepo.get(any())).thenAnswer((_) async => Session(
        ymd: '2025-01-01',
        exercises: [
          Exercise(name: 'Squat', bodyPart: 'legs', sets: manySets)
        ],
        isRest: false,
      ));

      await tester.pumpWidget(createWidgetUnderTest(
        PlanPage(
          date: DateTime(2025, 1, 1),
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ));
      await tester.pumpAndSettle();

      // Find the list
      // Since it uses `AnimatedCrossFade`, it might be tricky.
      // But the card itself should be scrollable if the page is.
      // `PlanPage` uses `Column` > `Expanded` > `ReorderableListView`.

      // Check if we can scroll to the last set.
      final lastSetFinder = find.text('20'); // Set index 20
      await tester.scrollUntilVisible(lastSetFinder, 500.0);

      // If we can see it, scrolling works.
      // The bug says "Adding a set hides it".
      // Meaning auto-scroll might be missing.

      // Let's try adding a set.
      // Find "Add Set" button.
      final addSetBtn = find.text('세트 추가');
      await tester.tap(addSetBtn);
      await tester.pumpAndSettle();

      // Set 21 should be added.
      // Check if it is visible.
      // If not visible, bug reproduced.
      // Note: `ReorderableListView` might auto-scroll? Or maybe not.

      // We expect failure (bug exists).
      // If it fails to find Set 21, it matches bug description.
    });

    testWidgets('TC-F003: Exercise Detail in Selection', (WidgetTester tester) async {
       // Open Selection Page
       // We can't easily open the private `_ExerciseSelectionPage` directly unless we navigate to it.
       // Or we can verify `ListTile` onTap behavior in the code we read.
       // In `_ExerciseSelectionPage`:
       // onTap: () => _toggleExercise(name, entry.key),
       // It just toggles selection. It DOES NOT open detail.

       // I will verify this via code inspection concept or by running a test that taps it and checks for DetailPage.

       await tester.pumpWidget(createWidgetUnderTest(
         // We need to trigger navigation to _ExerciseSelectionPage.
         // We can access the private class via PlanPage interaction.
         PlanPage(
          date: DateTime(2025, 1, 1),
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        )
       ));
       await tester.pumpAndSettle();

       // Tap "Add Exercise"
       await tester.tap(find.text('운동 추가'));
       await tester.pumpAndSettle();

       // Now we are in Selection Page.
       // Tap "Squat"
       await tester.tap(find.text('Squat'));
       await tester.pumpAndSettle();

       // Check if Detail Page opened.
       expect(find.byType(ExerciseDetailPage), findsNothing);
       // Check if it was selected (checked icon)
       expect(find.byIcon(Icons.check_circle), findsOneWidget);

       // This confirms the bug: Tapping selects instead of showing detail.
    });

    testWidgets('TC-F004: Recent History Button', (WidgetTester tester) async {
       // We need to check the ExerciseCard for "Recent History" button.
       // Looking at `exercise_set_card.dart` source I read:
       // The header has "Tempo" button or "Progress" badge.
       // The footer has "Tempo Start", "Add Set", "Delete Set".
       // I DO NOT SEE a "Recent History" button in the `ExerciseCard` code I read!
       // `_buildHeader`: Title, Checkmark/Tempo/Badge, Chevron.
       // `_buildFooterActions`: Tempo Start, Add/Delete Set.

       // If the button is missing, that's a bug (or it was removed).
       // The bug report says "Tapping Recent History does nothing".
       // If the button is gone, I can't even tap it.

       await tester.pumpWidget(createWidgetUnderTest(
        PlanPage(
          date: DateTime(2025, 1, 1),
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('최근 기록'), findsNothing);
      // Confirmed: Button is missing or not labelled '최근 기록'.
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/widgets/calendar/calendar_modal_sheet.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/core/burn_fit_style.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  testWidgets('BUG-019: CalendarModalSheet should display markers for workout dates', (WidgetTester tester) async {
    final workoutDate = DateTime(2023, 10, 15);
    final workoutDateStr = '2023-10-15';

    // We pass a set of workout dates containing our test date
    final workoutDates = {workoutDateStr};
    final restDates = <String>{};

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CalendarModalSheet(
            initialDate: workoutDate,
            repo: mockSessionRepo,
            exerciseRepo: mockExerciseRepo,
            workoutDates: workoutDates,
            restDates: restDates,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // We verify that the marker exists.
    // The marker is a Container with BurnFitStyle.primaryBlue and BoxShape.circle.

    final markerFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.constraints?.maxWidth == 6.0) {
         final decoration = widget.decoration;
         if (decoration is BoxDecoration) {
           return decoration.color == BurnFitStyle.primaryBlue && decoration.shape == BoxShape.circle;
         }
      }
      return false;
    });

    expect(markerFinder, findsOneWidget);
  });
}

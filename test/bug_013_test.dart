import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/widgets/calendar/calendar_modal_sheet.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// Create simple mocks since we don't need behavior for this UI test
class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  Widget createWidgetUnderTest(Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      home: Scaffold(
        body: CalendarModalSheet(
          initialDate: DateTime(2025, 1, 1), // January 1, 2025
          repo: mockRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ),
    );
  }

  testWidgets('BUG-013: CalendarModalSheet displays English month name in English locale', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest(const Locale('en')));
    await tester.pumpAndSettle();

    // Assert
    // DateFormat.yMMMM('en') usually outputs "January 2025"
    expect(find.textContaining('January'), findsOneWidget, reason: "Month name should be in English");
  });

  testWidgets('BUG-013: CalendarModalSheet displays Korean month name in Korean locale', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(createWidgetUnderTest(const Locale('ko')));
    await tester.pumpAndSettle();

    // Assert
    // DateFormat.yMMMM('ko') usually outputs "2025년 1월"
    expect(find.textContaining('1월'), findsOneWidget, reason: "Month name should be in Korean");
  });
}

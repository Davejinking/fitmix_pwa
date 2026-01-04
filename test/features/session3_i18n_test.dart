import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/pages/calendar_page.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockUserRepo mockUserRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockUserRepo = MockUserRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  testWidgets('TC-F005: Calendar Page i18n (BUG-024)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ko')],
        locale: const Locale('en'),
        home: CalendarPage(
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check for specific English text that should appear on Calendar page
    // If it's hardcoded to Korean, this will fail.
    // Assuming "Calendar" or "Today" or specific UI elements have localization.
    // Let's assume we expect "Calendar" title if it has an AppBar.
    // If not, maybe "Sun", "Mon" etc.
    // We'll search for "Mon" (Monday).
    expect(find.text('Mon'), findsOneWidget);
  });

  testWidgets('TC-F006: Upgrade Page i18n (BUG-009)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ko')],
        locale: const Locale('en'),
        home: const UpgradePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('TC-F007: UserInfoFormPage i18n (BUG-010)', (WidgetTester tester) async {
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ko')],
        locale: const Locale('en'),
        home: UserInfoFormPage(userRepo: mockUserRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });
}

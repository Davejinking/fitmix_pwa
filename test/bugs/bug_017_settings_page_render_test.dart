import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/pages/settings_page.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

// Mocks
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSessionRepo extends Mock implements SessionRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockUserRepo mockUserRepo;
  late MockExerciseLibraryRepo mockExerciseLibraryRepo;
  late MockSessionRepo mockSessionRepo;
  late MockSettingsRepo mockSettingsRepo;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockUserRepo = MockUserRepo();
    mockExerciseLibraryRepo = MockExerciseLibraryRepo();
    mockSessionRepo = MockSessionRepo();
    mockSettingsRepo = MockSettingsRepo();
    mockAuthRepo = MockAuthRepo();
  });

  testWidgets('BUG-017: SettingsPage should render without error (Unused imports check)', (WidgetTester tester) async {
    // The bug report mentions an unused import in settings_page.dart.
    // While we can't test "unused imports" via WidgetTest, we can verify
    // that the page renders correctly and the fix (removing it) didn't break anything.

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(
          userRepo: mockUserRepo,
          exerciseRepo: mockExerciseLibraryRepo,
          sessionRepo: mockSessionRepo,
          settingsRepo: mockSettingsRepo,
          authRepo: mockAuthRepo,
        ),
      ),
    );

    // Verify the page title 'Settings' (or '설정' in Korean default) exists
    // We use a finder that matches the localized string or key
    expect(find.byType(AppBar), findsOneWidget);

    // Since default locale might be English in test environment
    expect(find.text('Settings'), findsOneWidget);
  });
}

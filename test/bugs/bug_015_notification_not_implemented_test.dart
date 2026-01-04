import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/home_page.dart';
import 'package:fitmix_pwa/pages/notifications_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockUserRepo mockUserRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late MockSettingsRepo mockSettingsRepo;
  late MockAuthRepo mockAuthRepo;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockUserRepo = MockUserRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
    mockSettingsRepo = MockSettingsRepo();
    mockAuthRepo = MockAuthRepo();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  testWidgets('BUG-015: Notification icon should navigate to NotificationsPage', (WidgetTester tester) async {
    // Setup
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(
          sessionRepo: mockSessionRepo,
          userRepo: mockUserRepo,
          exerciseRepo: mockExerciseRepo,
          settingsRepo: mockSettingsRepo,
          authRepo: mockAuthRepo,
        ),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/notifications': (context) => const NotificationsPage(),
        },
      ),
    );

    // Find notification icon
    final iconFinder = find.byIcon(Icons.notifications_outlined);
    expect(iconFinder, findsOneWidget);

    // Tap it
    await tester.tap(iconFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Wait for animation

    // Verify navigation to NotificationsPage (by type or by route)
    expect(find.byType(NotificationsPage), findsOneWidget);
  });
}

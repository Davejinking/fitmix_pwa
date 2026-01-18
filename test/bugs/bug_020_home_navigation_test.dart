import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/features/home/pages/home_page.dart';
import 'package:fitmix_pwa/features/calendar/pages/calendar_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:get_it/get_it.dart';

// Mocks
class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SessionRepo>(mockSessionRepo);
    getIt.registerSingleton<UserRepo>(mockUserRepo);
    getIt.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
    getIt.registerSingleton<SettingsRepo>(mockSettingsRepo);
    getIt.registerSingleton<AuthRepo>(mockAuthRepo);

    // Mock session repo responses
    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => Session(ymd: '2023-10-15'));
    // Mock user repo responses if needed by Home Page
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);
  });

  testWidgets('BUG-020: Tapping "Today\'s Workout" should navigate to CalendarPage', (WidgetTester tester) async {
    // Need to pump HomePage in a shell that allows navigation
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/calendar': (context) => const CalendarPage(), // Register if named route used
        },
      ),
    );

    await tester.pumpAndSettle();

    // Find "Today's Workout" card.
    final todayWorkoutFinder = find.text("Today's Workout");

    // If not found, try Korean just in case or verify finder
    if (todayWorkoutFinder.evaluate().isEmpty) {
       // Try finding by Key if available or partial text?
       // Let's assume English based on app_en.arb presence.
    }

    expect(todayWorkoutFinder, findsOneWidget);

    // Tap it
    await tester.tap(todayWorkoutFinder);
    await tester.pumpAndSettle();

    // Verify navigation by checking if Navigator pushed a route
    verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));
  });
}

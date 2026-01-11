import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/home_page.dart';
import 'package:fitmix_pwa/pages/notifications_page.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/models/session.dart';

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

    // Default mocks
    when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
    when(() => mockSessionRepo.get(any())).thenAnswer((_) async => Session(ymd: '2024-01-01'));
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);
  });

  testWidgets('Session 1 Missing Regression Tests', (WidgetTester tester) async {
    registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ko')],
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

    // Pump to settle UI
    for (int i = 0; i < 20; i++) {
       await tester.pump(const Duration(milliseconds: 100));
    }

    // TC-R006: Home Profile/Upgrade Access
    // Upgrade Icon: Icons.star_outline
    final upgradeIcon = find.byIcon(Icons.star_outline);
    expect(upgradeIcon, findsOneWidget);

    await tester.tap(upgradeIcon);

    // Pump nav
    for (int i = 0; i < 10; i++) {
       await tester.pump(const Duration(milliseconds: 100));
    }
    verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));

    // Reset for next check
    reset(mockNavigatorObserver);

    // Profile Icon: Icons.person_outlined
    final profileIcon = find.byIcon(Icons.person_outlined);
    expect(profileIcon, findsOneWidget);

    await tester.tap(profileIcon);

    // Pump nav
    for (int i = 0; i < 10; i++) {
       await tester.pump(const Duration(milliseconds: 100));
    }
    verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));

    // TC-R014: Home Status (Blue/Green/Grey)
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text) {
        return (widget.data ?? '').contains('Not Completed') || (widget.data ?? '').contains('미완료');
      }
      return false;
    }), findsOneWidget);
  });
}

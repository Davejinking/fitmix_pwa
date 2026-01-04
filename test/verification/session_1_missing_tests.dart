import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/home_page.dart';
import 'package:fitmix_pwa/pages/profile_page.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/models/user_profile.dart';

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

    // Provide a valid profile
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
      weight: 70.0,
      height: 175,
      birthDate: DateTime(1990, 1, 1),
      gender: 'male',
    ));
  });

  Widget createHomePage() {
    return MaterialApp(
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
        '/profile': (context) => ProfilePage(userRepo: mockUserRepo, authRepo: mockAuthRepo),
        '/upgrade': (context) => const UpgradePage(),
      },
    );
  }

  testWidgets('TC-R006: Home to Profile/Upgrade navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createHomePage());
    await tester.pumpAndSettle();

    // 1. Profile Icon (person_outlined in HeaderComponent)
    final profileIcon = find.byIcon(Icons.person_outlined);
    expect(profileIcon, findsOneWidget);

    // Tap Profile
    await tester.tap(profileIcon);
    await tester.pumpAndSettle();

    // Should navigate to UserInfoFormPage (as per HeaderComponent implementation in HomePage)
    expect(find.byType(UserInfoFormPage), findsOneWidget);

    // Go back
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 2. Upgrade Icon (star_outline in HeaderComponent)
    final starIcon = find.byIcon(Icons.star_outline);
    expect(starIcon, findsOneWidget);

    // Tap Star
    await tester.tap(starIcon);
    await tester.pumpAndSettle();

    // Should navigate to UpgradePage
    expect(find.byType(UpgradePage), findsOneWidget);
  });

  testWidgets('TC-R007: Profile Page Loading', (WidgetTester tester) async {
     when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
       weight: 75.0,
       height: 180,
       birthDate: DateTime(1990, 1, 1),
       gender: 'male'
     ));

     await tester.pumpWidget(MaterialApp(
       localizationsDelegates: AppLocalizations.localizationsDelegates,
       supportedLocales: AppLocalizations.supportedLocales,
       home: ProfilePage(userRepo: mockUserRepo, authRepo: mockAuthRepo),
     ));

     await tester.pumpAndSettle();

     // Check if values are displayed
     // Note: app_en.arb says "height": "Height: {value} cm"
     // So we expect "Height: 180 cm"
     expect(find.textContaining('180'), findsOneWidget);
     expect(find.textContaining('75'), findsOneWidget);
  });

  testWidgets('TC-R019: Direct Start (PlanPage hidden)', (WidgetTester tester) async {
     // TODO: Implement logic to verify Direct Start if applicable.
  });
}

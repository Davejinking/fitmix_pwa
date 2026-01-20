// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/home_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/data/routine_repo.dart';
import 'package:fitmix_pwa/core/service_locator.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}
class MockRoutineRepo extends Mock implements RoutineRepo {}

void main() {
  group('BUG-008: My Goal Edit Navigation', () {
    late MockSessionRepo mockSessionRepo;
    late MockUserRepo mockUserRepo;
    late MockExerciseLibraryRepo mockExerciseRepo;
    late MockSettingsRepo mockSettingsRepo;
    late MockAuthRepo mockAuthRepo;
    late MockRoutineRepo mockRoutineRepo;

    setUp(() async {
      mockSessionRepo = MockSessionRepo();
      mockUserRepo = MockUserRepo();
      mockExerciseRepo = MockExerciseLibraryRepo();
      mockSettingsRepo = MockSettingsRepo();
      mockAuthRepo = MockAuthRepo();
      mockRoutineRepo = MockRoutineRepo();

      await getIt.reset();
      getIt.registerSingleton<SessionRepo>(mockSessionRepo);
      getIt.registerSingleton<UserRepo>(mockUserRepo);
      getIt.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
      getIt.registerSingleton<SettingsRepo>(mockSettingsRepo);
      getIt.registerSingleton<AuthRepo>(mockAuthRepo);
      getIt.registerSingleton<RoutineRepo>(mockRoutineRepo);
      
      when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);
      when(() => mockSessionRepo.getSessionsInRange(any(), any())).thenAnswer((_) async => []);
      when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
      when(() => mockSessionRepo.ymd(any())).thenReturn('2023-01-01');
      when(() => mockSessionRepo.get(any())).thenAnswer((_) async => null);
    });

    testWidgets('Clicking Edit on My Goal card should navigate to Goal Settings, not Profile', (WidgetTester tester) async {
      final mockObserver = NavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
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
          home: const HomePage(),
          navigatorObservers: [mockObserver],
          routes: {
            '/profile': (context) => UserInfoFormPage(userRepo: mockUserRepo),
            '/goal_settings': (context) => const Scaffold(body: Text('Goal Settings Page')),
          },
        ),
      );

      // Animation settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find "MONTHLY GOAL" text (Current UI)
      expect(find.text('MONTHLY GOAL'), findsOneWidget);

      // Find the edit button - currently missing in UI, so this is expected to fail initially
      final editButton = find.widgetWithIcon(IconButton, Icons.edit);
      expect(editButton, findsOneWidget, reason: 'Edit button should exist on Goal card');

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Assertion for BUG-008
      expect(find.byType(UserInfoFormPage), findsNothing, reason: "BUG-008: Should not navigate to UserInfoFormPage");
      expect(find.text('Goal Settings Page'), findsOneWidget, reason: "Should navigate to Goal Settings page");
    });
  });
}

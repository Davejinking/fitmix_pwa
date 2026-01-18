// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/features/home/pages/home_page.dart';
import 'package:fitmix_pwa/features/auth/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  group('BUG-008: My Goal Edit Navigation', () {
    late MockSessionRepo mockSessionRepo;
    late MockUserRepo mockUserRepo;
    late MockExerciseLibraryRepo mockExerciseRepo;
    late MockSettingsRepo mockSettingsRepo;
    late MockAuthRepo mockAuthRepo;

    setUp(() {
      mockSessionRepo = MockSessionRepo();
      mockUserRepo = MockUserRepo();
      mockExerciseRepo = MockExerciseLibraryRepo();
      mockSettingsRepo = MockSettingsRepo();
      mockAuthRepo = MockAuthRepo();

      final getIt = GetIt.instance;
      getIt.reset();
      getIt.registerSingleton<SessionRepo>(mockSessionRepo);
      getIt.registerSingleton<UserRepo>(mockUserRepo);
      getIt.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
      getIt.registerSingleton<SettingsRepo>(mockSettingsRepo);
      getIt.registerSingleton<AuthRepo>(mockAuthRepo);
      
      when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);
    });

    testWidgets('Clicking Edit on My Goal card should navigate to Goal Settings, not Profile', (WidgetTester tester) async {
      final mockObserver = NavigatorObserver();

      // Note: This test expects HomePage to be renderable.
      // If environment prevents Hive initialization, this acts as a template for the fix verification.
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          navigatorObservers: [mockObserver],
          routes: {
            '/profile': (context) => UserInfoFormPage(userRepo: mockUserRepo),
            '/goal_settings': (context) => const Scaffold(body: Text('Goal Settings')),
          },
        ),
      );

      // Find "나의 목표" text
      expect(find.text('나의 목표'), findsOneWidget);

      // Find the edit button
      final editButton = find.widgetWithIcon(IconButton, Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Assertion for BUG-008
      expect(find.byType(UserInfoFormPage), findsNothing, reason: "BUG-008: Should not navigate to UserInfoFormPage");
      expect(find.text('Goal Settings'), findsOneWidget, reason: "Should navigate to Goal Settings page");
    });
  });
}

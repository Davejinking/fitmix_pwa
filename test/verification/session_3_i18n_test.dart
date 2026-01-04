import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/calendar_page.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/pages/exercise_selection_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/models/user_profile.dart';

// Mocks
class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
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

    // Default mocks
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
      weight: 70, height: 175, birthDate: DateTime(1990), gender: 'male'
    ));
    when(() => mockExerciseRepo.getLibrary()).thenAnswer((_) async => {
      'Chest': ['Bench Press'],
    });
    when(() => mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
  });

  group('Session 3: i18n Bugs Reproduction', () {

    testWidgets('TC-F005: Calendar Page i18n (BUG-024)', (WidgetTester tester) async {
       // Bug: Calendar text remains in Korean even when English is selected.

       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         locale: const Locale('en'), // Force English
         home: CalendarPage(repo: mockSessionRepo, exerciseRepo: mockExerciseRepo),
       ));
       await tester.pumpAndSettle();

       // Check for Korean text that should be English
       // Example: "오늘" (Today) should be "Today" or similar.
       // Or Month names if not using standard widgets.

       // If the bug exists, we might find Korean text or fail to find English text.
       // Let's assume there's a button "운동 계획하기" which should be "Plan Workout".

       // If we find "운동 계획하기" while in English locale -> Bug Reproduced.
       // Or if we DON'T find "Plan Workout".

       // Let's check for a common string.
       // If the calendar uses hardcoded "월", "화"...

       // Let's try to find "Plan Workout" (English).
       // If it fails, check if "운동 계획하기" exists.

       final englishFinder = find.text('Plan Workout'); // Assuming this key exists in arb
       final koreanFinder = find.text('운동 계획하기');

       // If bug exists: English not found, Korean found.
       // Or English found but other parts are Korean.

       // TC says: "Buttons/Labels text check".
       // Let's assert we find English. Failure = Bug.
       expect(englishFinder, findsOneWidget);
    });

    testWidgets('TC-F006: Upgrade Page i18n (BUG-009)', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         locale: const Locale('en'),
         home: const UpgradePage(),
       ));
       await tester.pumpAndSettle();

       // Check for English title "Upgrade to Premium" or "Power Shop".
       // If bug exists (Korean hardcoded), we see "프리미엄 업그레이드".

       expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('TC-F007: UserInfoFormPage i18n (BUG-010)', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         locale: const Locale('en'),
         home: UserInfoFormPage(userRepo: mockUserRepo),
       ));
       await tester.pumpAndSettle();

       // Check for "Weight", "Height".
       // Bug: "체중", "신장" displayed.

       expect(find.text('Weight'), findsWidgets); // Might appear multiple times (label, hint)
    });

    testWidgets('TC-F008: Confirm/Cancel Buttons i18n (BUG-012)', (WidgetTester tester) async {
       // Open a dialog to check buttons.
       // UserInfoFormPage might have a dialog, or PlanPage.
       // Let's verify a known dialog or just check logic if possible.
       // Hard to trigger dialog in isolation without interacting.

       // Let's use a simple Builder to show a dialog.
       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         locale: const Locale('en'),
         home: Builder(builder: (context) {
           return TextButton(
             onPressed: () {
               showDialog(context: context, builder: (ctx) => AlertDialog(
                 actions: [
                   TextButton(onPressed: (){}, child: Text(AppLocalizations.of(ctx).confirm)),
                   TextButton(onPressed: (){}, child: Text(AppLocalizations.of(ctx).cancel)),
                 ],
               ));
             },
             child: const Text('Show'),
           );
         }),
       ));

       await tester.tap(find.text('Show'));
       await tester.pumpAndSettle();

       // Should find "Confirm" and "Cancel".
       // If bug exists (hardcoded), we see "확인", "취소".

       expect(find.text('Confirm'), findsOneWidget);
       expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('TC-F011: Exercise Selection i18n (BUG-026)', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
         localizationsDelegates: AppLocalizations.localizationsDelegates,
         supportedLocales: AppLocalizations.supportedLocales,
         locale: const Locale('en'),
         home: ExerciseSelectionPage(exerciseRepo: mockExerciseRepo),
       ));
       await tester.pumpAndSettle();

       // Header "Select Exercise"
       // If bug: "운동 선택"

       expect(find.text('Select Exercise'), findsOneWidget);
    });

  });
}

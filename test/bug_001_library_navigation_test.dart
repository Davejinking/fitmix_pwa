import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/features/library/pages/library_page.dart';
import 'package:fitmix_pwa/features/home/pages/shell_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/user_profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // ymd 포맷팅을 위해 추가
import 'package:get_it/get_it.dart';

// Mocks with mocktail
class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockSessionRepo sessionRepo;
  late MockExerciseLibraryRepo exerciseRepo;
  late MockUserRepo userRepo;
  late MockSettingsRepo settingsRepo;
  late MockAuthRepo authRepo;
  late Directory tempDir;

  setUp(() async {
    // Hive initialization for tests
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    sessionRepo = MockSessionRepo();
    exerciseRepo = MockExerciseLibraryRepo();
    userRepo = MockUserRepo();
    settingsRepo = MockSettingsRepo();
    authRepo = MockAuthRepo();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SessionRepo>(sessionRepo);
    getIt.registerSingleton<ExerciseLibraryRepo>(exerciseRepo);
    getIt.registerSingleton<UserRepo>(userRepo);
    getIt.registerSingleton<SettingsRepo>(settingsRepo);
    getIt.registerSingleton<AuthRepo>(authRepo);

    // Stubbing required methods
    when(() => exerciseRepo.init()).thenAnswer((_) async {});
    when(() => exerciseRepo.getLibrary()).thenAnswer((_) async => {});

    when(() => userRepo.init()).thenAnswer((_) async {});
    when(() => userRepo.getUserProfile()).thenAnswer((_) async => null);

    when(() => settingsRepo.init()).thenAnswer((_) async {});
    when(() => settingsRepo.getThemeMode()).thenAnswer((_) async => ThemeMode.system);
    when(() => settingsRepo.isOnboardingComplete()).thenAnswer((_) async => true);

    // SessionRepo stubbing
    when(() => sessionRepo.init()).thenAnswer((_) async {});
    when(() => sessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);
    when(() => sessionRepo.listAll()).thenAnswer((_) async => []);

    // ymd 메서드는 String을 반환하는 동기 메서드입니다.
    // ArgumentMatcher를 사용하여 모든 DateTime 입력에 대해 처리합니다.
    when(() => sessionRepo.ymd(any())).thenAnswer((invocation) {
      final date = invocation.positionalArguments[0] as DateTime;
      return DateFormat('yyyy-MM-dd').format(date);
    });

    when(() => sessionRepo.getSessionsInRange(any(), any())).thenAnswer((_) async => []);
    when(() => sessionRepo.get(any())).thenAnswer((_) async => null);

    // AuthRepo stubbing
    when(() => authRepo.currentUser).thenReturn(null);
  });

  tearDown(() async {
    try {
        await Hive.close();
        await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Widget createShellPage() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko')],
      home: const ShellPage(),
    );
  }

  group('BUG-001 Navigation Tests', () {
    testWidgets('Library tab switches correctly and displays content without nested Scaffold issues', (WidgetTester tester) async {
      // Register fallback values for any() if needed (DateTime is primitive so usually fine, but let's be safe)
      registerFallbackValue(DateTime.now());

      // 1. Load ShellPage
      await tester.pumpWidget(createShellPage());

      // Allow initial data loading to complete
      await tester.pump(const Duration(seconds: 1));

      // 2. Verify initial page is Home (index 0)
      expect(find.text('홈'), findsWidgets);

      // 3. Navigate to Library tab (index 2)
      await tester.tap(find.text('라이브러리'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 500)); // Finish animation

      // 4. Verify LibraryPage is displayed
      expect(find.text('라이브러리'), findsWidgets);

      // 5. Verify internal TabBar exists
      // Wait for internal loading
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('가슴'), findsOneWidget);
      expect(find.text('등'), findsOneWidget);

      // 6. Switch internal tabs in LibraryPage
      await tester.tap(find.text('등'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Wait for tab animation

      // 7. Verify structure matches the fix

      final shellPageFinder = find.byType(ShellPage);
      // ShellPage has a Scaffold
      final shellScaffoldFinder = find.descendant(of: shellPageFinder, matching: find.byType(Scaffold)).first;
      expect(shellScaffoldFinder, findsOneWidget);

      // Inside IndexedStack, the current child should be the Library tab wrapped in a Scaffold
      final indexedStackFinder = find.byType(IndexedStack);
      final libraryTabScaffoldFinder = find.descendant(
        of: indexedStackFinder,
        matching: find.byType(Scaffold)
      );

      expect(libraryTabScaffoldFinder, findsOneWidget);

      // LibraryPage itself should NOT have a Scaffold
      final libraryPageFinder = find.byType(LibraryPage);
      expect(libraryPageFinder, findsOneWidget);

      final scaffoldInsideLibraryPage = find.descendant(
        of: libraryPageFinder,
        matching: find.byType(Scaffold)
      );

      expect(scaffoldInsideLibraryPage, findsNothing, reason: 'LibraryPage should not contain a Scaffold');
    });
  });
}

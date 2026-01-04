import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/pages/library_page_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/services/exercise_db_service.dart';
import 'package:fitmix_pwa/models/exercise_db.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';

// Mocks
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockExerciseDBService extends Mock implements ExerciseDBService {}
class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockExerciseLibraryRepo mockRepo;
  late MockExerciseDBService mockService;
  late MockSessionRepo mockSessionRepo;

  setUpAll(() {
    registerFallbackValue(ExerciseDB(
      id: 'test',
      name: 'Test',
      bodyPart: 'chest',
      equipment: 'barbell',
      gifUrl: '',
      target: 'pectorals',
      secondaryMuscles: [],
      instructions: [],
    ));
  });

  setUp(() {
    mockRepo = MockExerciseLibraryRepo();
    mockService = MockExerciseDBService();
    mockSessionRepo = MockSessionRepo();

    when(() => mockRepo.init()).thenAnswer((_) async {});
    when(() => mockRepo.getLibrary()).thenAnswer((_) async => {});
    when(() => mockService.getAllExercises(limit: any(named: 'limit')))
        .thenAnswer((_) async => [
              ExerciseDB(
                id: '1',
                name: 'Bench Press',
                bodyPart: 'chest',
                equipment: 'barbell',
                gifUrl: 'url',
                target: 'pectorals',
                secondaryMuscles: [],
                instructions: [],
              ),
              ExerciseDB(
                id: '2',
                name: 'Squat',
                bodyPart: 'upper legs',
                equipment: 'barbell',
                gifUrl: 'url',
                target: 'quads',
                secondaryMuscles: [],
                instructions: [],
              ),
            ]);
  });

  Widget createWidgetUnderTest(Widget child, {Locale locale = const Locale('ko')}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  group('Session 1: Regression Tests', () {
    testWidgets('TC-R001: Library Tab Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        LibraryPageV2(service: mockService, customRepo: mockRepo),
      ));
      await tester.pumpAndSettle();

      // Verify tabs exist
      expect(find.text('가슴'), findsOneWidget);
      expect(find.text('등'), findsOneWidget);

      // Tap on 'Back' (등) tab
      await tester.tap(find.text('등'));
      await tester.pumpAndSettle();

      // Since we didn't mock data specifically for 'back', just verifying tap works without crash
      expect(find.text('등'), findsOneWidget);
    });

    testWidgets('TC-R002: Library Detail Page', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        LibraryPageV2(service: mockService, customRepo: mockRepo),
      ));
      await tester.pumpAndSettle();

      // Switch to chest
      await tester.tap(find.text('가슴'));
      await tester.pumpAndSettle();

      // Localized name 'Bench Press' -> '벤치프레스' in Korean
      expect(find.text('벤치프레스'), findsOneWidget);

      // Tap to navigate
      await tester.tap(find.text('벤치프레스'));
      await tester.pumpAndSettle();

      // Verify Detail Page
      expect(find.byType(ExerciseDetailPage), findsOneWidget);
      expect(find.text('벤치프레스'), findsOneWidget);
    });

    testWidgets('TC-R009: Library Search', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        LibraryPageV2(service: mockService, customRepo: mockRepo),
      ));
      await tester.pumpAndSettle();

      // Switch to chest
      await tester.tap(find.text('가슴'));
      await tester.pumpAndSettle();

      // Search (using Korean)
      await tester.enterText(find.byType(TextField), '벤치');
      await tester.pumpAndSettle();

      expect(find.text('벤치프레스'), findsOneWidget);

      // Search something non-existent
      await tester.enterText(find.byType(TextField), 'Zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('벤치프레스'), findsNothing);
    });

    testWidgets('TC-R010: Library Translation (Japanese)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        LibraryPageV2(service: mockService, customRepo: mockRepo),
        locale: const Locale('ja'),
      ));
      await tester.pumpAndSettle();

      // Verify Tab names in Japanese
      // "Chest" -> "胸"
      expect(find.text('胸'), findsOneWidget);
    });
  });
}

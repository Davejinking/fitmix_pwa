// T18: 최근 기록 조회 안전성 (Recent History Retrieval Safety)
// 목표: ExerciseDetailPage에서 최근 기록 조회 시 크래시가 발생하지 않는지 확인.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/exercise_db.dart';
import 'package:get_it/get_it.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

// Generate Mocks
@GenerateMocks([SessionRepo, ExerciseLibraryRepo])
import 'qa_t18_recent_history_test.mocks.dart';

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();

    GetIt.I.reset();
    GetIt.I.registerSingleton<SessionRepo>(mockSessionRepo);
    GetIt.I.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ExerciseDetailPage(
        exerciseName: 'Bench Press',
        exerciseRepo: mockExerciseRepo, // Pass explicitly if constructor allows, otherwise it uses GetIt
      ),
    );
  }

  testWidgets('T18: ExerciseDetailPage should load without crash when history is empty', (WidgetTester tester) async {
    // Arrange
    when(mockSessionRepo.getRecentExerciseHistory(any)).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Bench Press'), findsOneWidget); // Title
    expect(find.text('Chest'), findsOneWidget); // Body part
  });

  testWidgets('T18: ExerciseDetailPage should load without crash with history data', (WidgetTester tester) async {
    // Arrange
    final history = [
      ExerciseHistoryRecord(
        date: '2023-10-01',
        sets: [], // Empty sets shouldn't crash
      ),
    ];
    when(mockSessionRepo.getRecentExerciseHistory(any)).thenAnswer((_) async => history);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Bench Press'), findsOneWidget);
  });
}

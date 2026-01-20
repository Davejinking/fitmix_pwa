import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

import 'exercise_detail_robustness_test.mocks.dart';

@GenerateMocks([SessionRepo, ExerciseLibraryRepo])
void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('T19: ExerciseDetailPage displays empty state correctly when history is empty', (WidgetTester tester) async {
    // Arrange
    const exerciseName = 'Bench Press';
    when(mockSessionRepo.getRecentExerciseHistory(exerciseName))
        .thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createTestWidget(
      ExerciseDetailPage(
        exerciseName: exerciseName,
        sessionRepo: mockSessionRepo,
        exerciseRepo: mockExerciseRepo,
      ),
    ));

    // Wait for async operations (loading history)
    await tester.pump(); // Start InitState future
    await tester.pump(const Duration(milliseconds: 100)); // Wait for completion

    // Assert
    // 1. Verify UI components are present
    expect(find.text('Bench Press'), findsOneWidget); // Localized name fallback or actual key depending on l10n

    // 2. Verify Empty State Message
    expect(find.text('기록이 없습니다'), findsOneWidget);

    // 3. Verify no crash
    expect(tester.takeException(), isNull);
  });
}

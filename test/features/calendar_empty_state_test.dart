import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:fitmix_pwa/pages/calendar_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/routine_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/models/session.dart';

import 'calendar_empty_state_test.mocks.dart';

// 1. Generate Mocks
@GenerateMocks([SessionRepo, ExerciseLibraryRepo, RoutineRepo, UserRepo])
void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;
  late MockRoutineRepo mockRoutineRepo;
  late MockUserRepo mockUserRepo;

  setUp(() {
    // 2. Initialize Mocks
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
    mockRoutineRepo = MockRoutineRepo();
    mockUserRepo = MockUserRepo();

    // 3. Register Mocks with GetIt
    GetIt.I.reset();
    GetIt.I.registerSingleton<SessionRepo>(mockSessionRepo);
    GetIt.I.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
    GetIt.I.registerSingleton<RoutineRepo>(mockRoutineRepo);
    GetIt.I.registerSingleton<UserRepo>(mockUserRepo);
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('T20: CalendarPage displays empty state without crash when history is empty', (WidgetTester tester) async {
    // Arrange
    final today = DateTime.now();
    // get(ymd) returns null for empty day
    when(mockSessionRepo.ymd(any)).thenReturn('2025-05-20');
    when(mockSessionRepo.get(any)).thenAnswer((_) async => null);

    // getWorkoutSessions returns empty list
    when(mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);

    // listAll returns empty list (used for rest dates)
    when(mockSessionRepo.listAll()).thenAnswer((_) async => []);

    // Act
    await tester.pumpWidget(createTestWidget(const CalendarPage()));

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Assert
    // 1. Verify Empty State UI
    expect(find.byIcon(Icons.fitness_center), findsOneWidget); // Empty state icon
    expect(find.byIcon(Icons.add), findsOneWidget); // Add button in bottom bar

    // 2. Verify no crash
    expect(tester.takeException(), isNull);
  });
}

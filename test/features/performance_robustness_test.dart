
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/calendar_page.dart';
import 'package:fitmix_pwa/pages/analysis_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/routine_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/models/user_profile.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/widgets/calendar/week_strip.dart';
import 'package:fitmix_pwa/widgets/workout_heatmap.dart';

// Manual Mocks to avoid build_runner dependency and null-safety issues with `any`
class ManualMockSessionRepo extends Mock implements SessionRepo {
  final List<Session> _sessions;
  ManualMockSessionRepo(this._sessions);

  @override
  String ymd(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  DateTime ymdToDateTime(String ymd) {
    final parts = ymd.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  @override
  Future<List<Session>> getWorkoutSessions() async => _sessions;

  @override
  Future<List<Session>> listAll() async => _sessions;

  @override
  Future<Session?> get(String ymd) async {
    // Return first session or null, simulating a hit
    if (_sessions.isNotEmpty) return _sessions.first;
    return null;
  }

  @override
  Future<void> put(Session s) async {} // No-op

  @override
  Future<void> markRest(String ymd, {required bool rest}) async {}
}

class ManualMockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class ManualMockUserRepo extends Mock implements UserRepo {
  @override
  Future<UserProfile?> getUserProfile() async {
    return UserProfile(
        weight: 70, height: 175, birthDate: DateTime(1990), gender: 'M'
      );
  }
}
class ManualMockRoutineRepo extends Mock implements RoutineRepo {}

void main() {
  late ManualMockSessionRepo mockSessionRepo;
  late ManualMockExerciseLibraryRepo mockExerciseRepo;
  late ManualMockUserRepo mockUserRepo;
  late ManualMockRoutineRepo mockRoutineRepo;

  // Helper to generate mass sessions
  List<Session> generateMassSessions(int count) {
    final sessions = <Session>[];
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final date = now.subtract(Duration(days: i));
      final ymd = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      sessions.add(Session(
        ymd: ymd,
        exercises: [
           Exercise(
            name: 'Bench Press',
            bodyPart: 'Chest',
            sets: [ExerciseSet(weight: 100, reps: 1, isCompleted: true)],
          )
        ],
        isCompleted: true,
      ));
    }
    return sessions;
  }

  setUp(() {
    final massSessions = generateMassSessions(365); // 1 year of data
    mockSessionRepo = ManualMockSessionRepo(massSessions);
    mockExerciseRepo = ManualMockExerciseLibraryRepo();
    mockUserRepo = ManualMockUserRepo();
    mockRoutineRepo = ManualMockRoutineRepo();

    GetIt.I.reset();
    GetIt.I.registerSingleton<SessionRepo>(mockSessionRepo);
    GetIt.I.registerSingleton<ExerciseLibraryRepo>(mockExerciseRepo);
    GetIt.I.registerSingleton<UserRepo>(mockUserRepo);
    GetIt.I.registerSingleton<RoutineRepo>(mockRoutineRepo);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('T29: Mass Data Calendar Performance', () {
    testWidgets('Should handle 365+ sessions gracefully in CalendarPage', (WidgetTester tester) async {
      // 1. Pump Widget
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko')],
          home: const CalendarPage(),
        ),
      );

      await tester.pumpAndSettle(); // Allow async loads to complete

      // 2. Verify Initial Load
      expect(find.byType(WeekStrip), findsOneWidget);

      // 3. Simulate Scroll (Calendar WeekStrip)
      final weekStrip = find.byType(WeekStrip);
      await tester.drag(weekStrip, const Offset(-500, 0));
      await tester.pumpAndSettle();

      await tester.drag(weekStrip, const Offset(500, 0));
      await tester.pumpAndSettle();

      // Pass if no exception
    });
  });

  group('T30: Mass Data Heatmap Performance', () {
    testWidgets('Should render heatmap with 365+ sessions without timeout', (WidgetTester tester) async {
      // 1. Pump Widget
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko')],
          home: const AnalysisPage(),
        ),
      );

      // 2. Measure Render Time (Implicitly via test timeout)
      await tester.pumpAndSettle();

      // 3. Verify Content
      expect(find.byType(WorkoutHeatmap), findsOneWidget);
      // Both "WORKOUTS 365" and "365 days streak" might appear, so just check at least one exists
      expect(find.textContaining('365'), findsAtLeastNWidgets(1));

      // Verify stats
      expect(find.text('WORKOUTS'), findsOneWidget);
      expect(find.text('TOTAL VOL'), findsOneWidget);
    });
  });
}

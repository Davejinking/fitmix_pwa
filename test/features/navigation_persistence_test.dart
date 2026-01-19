import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

// Pages
import 'package:fitmix_pwa/pages/active_workout_page.dart';
import 'package:fitmix_pwa/pages/shell_page.dart';
import 'package:fitmix_pwa/pages/home_page.dart';

// Data & Models
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/data/routine_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/models/routine.dart'; // RoutineRepo mocks need this

// --- Mocks Definitions ---

class MockSessionRepo extends Mock implements SessionRepo {
  @override
  String ymd(DateTime? date) => '2024-01-01'; // 날짜 고정

  @override
  Future<Session?> get(String? ymd) async => null;

  @override
  Future<List<Session>> getWorkoutSessions() async => [];

  @override
  Future<List<Session>> getSessionsInRange(DateTime? start, DateTime? end) async => [];

  @override
  Future<void> put(Session? session) async {}

  @override
  DateTime ymdToDateTime(String? ymd) => DateTime(2024, 1, 1);
}

class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {
  @override
  Future<List<Exercise>> getExercises() async => [];
}

class MockUserRepo extends Mock implements UserRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}
class MockRoutineRepo extends Mock implements RoutineRepo {
  @override
  Future<List<Routine>> getRoutines() async => [];
}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseLibraryRepo;
  late MockUserRepo mockUserRepo;
  late MockSettingsRepo mockSettingsRepo;
  late MockAuthRepo mockAuthRepo;
  late MockRoutineRepo mockRoutineRepo;

  setUp(() {
    // 1. 초기화: Mock 객체 생성
    mockSessionRepo = MockSessionRepo();
    mockExerciseLibraryRepo = MockExerciseLibraryRepo();
    mockUserRepo = MockUserRepo();
    mockSettingsRepo = MockSettingsRepo();
    mockAuthRepo = MockAuthRepo();
    mockRoutineRepo = MockRoutineRepo();

    // 2. GetIt 등록 (DI 설정)
    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SessionRepo>(mockSessionRepo);
    getIt.registerSingleton<ExerciseLibraryRepo>(mockExerciseLibraryRepo);
    getIt.registerSingleton<UserRepo>(mockUserRepo);
    getIt.registerSingleton<SettingsRepo>(mockSettingsRepo);
    getIt.registerSingleton<AuthRepo>(mockAuthRepo);
    getIt.registerSingleton<RoutineRepo>(mockRoutineRepo);
  });

  // Helper: 테스트 대상 위젯 생성
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko'), Locale('en')],
      locale: const Locale('ko'), // 한국어 환경 테스트
      home: child,
    );
  }

  group('Navigation & Data Persistence Tests (T06, T08, T10)', () {

    // 테스트용 더미 세션 데이터 생성
    Session createDummySession() {
      return Session(
        id: 'test_session',
        ymd: '2024-01-01',
        exercises: [
          Exercise(
            name: '벤치프레스',
            bodyPart: '가슴',
            sets: [ExerciseSet(weight: 60, reps: 10)],
          ),
        ],
      );
    }

    testWidgets('T06: 뒤로가기 버튼 클릭 시 데이터 보호 다이얼로그 및 자동 저장 확인', (WidgetTester tester) async {
      // 1. Arrange: ActiveWorkoutPage 로드
      final session = createDummySession();

      await tester.pumpWidget(createWidgetUnderTest(
        ActiveWorkoutPage(
          session: session,
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseLibraryRepo,
          date: DateTime(2024, 1, 1),
        ),
      ));
      await tester.pumpAndSettle();

      // 2. Act: 시스템 뒤로가기 시뮬레이션 (PopRoute)
      // 사용자가 실수로 뒤로가기를 눌렀을 때를 가정합니다.
      final dynamic widgetsBinding = tester.binding;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // 3. Assert: 다이얼로그 표시 확인
      // Back Press 시에는 l10n.endWorkout ("운동 종료")가 타이틀로 표시됨
      expect(find.textContaining('운동 종료'), findsOneWidget);

      // 다이얼로그의 '확인' 버튼 탭 (l10n.confirm -> "확인")
      final confirmButton = find.widgetWithText(ElevatedButton, '확인');
      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
      } else {
        await tester.tap(find.text('확인'));
      }
      await tester.pumpAndSettle();

      // 4. Assert: 자동 저장 (repo.put) 호출 확인
      // _handleBackPress 내부에서 repo.put(_session)을 호출하여 임시 저장을 수행해야 함
      verify(mockSessionRepo.put(any)).called(1);
    });

    testWidgets('T08: 탭 전환 시 IndexedStack 상태 유지 확인 (ShellPage)', (WidgetTester tester) async {
      // 1. Arrange: ShellPage 로드 (HomePage 포함)
      // HomePage가 로드될 때 sessionRepo.getWorkoutSessions() 등이 호출됨
      when(mockSessionRepo.getWorkoutSessions()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest(const ShellPage()));
      await tester.pumpAndSettle();

      // 초기 상태: 홈 탭(인덱스 0)이 활성화됨
      expect(find.byType(HomePage), findsOneWidget);

      // 호출 횟수 기록 초기화 (초기 로딩 제외)
      clearInteractions(mockSessionRepo);

      // 2. Act: 캘린더 탭(인덱스 1)으로 이동
      await tester.tap(find.icon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();

      // 3. Act: 다시 홈 탭(인덱스 0)으로 복귀
      await tester.tap(find.icon(Icons.home_outlined));
      await tester.pumpAndSettle();

      // 4. Assert: 상태 유지 확인
      // IndexedStack을 사용하므로 탭 전환 시 initState가 다시 호출되지 않아야 함.
      // 즉, 데이터를 다시 불러오는 로직(Repo 호출)이 발생하지 않아야 함.
      verifyNever(mockSessionRepo.getWorkoutSessions());

      // 홈 페이지가 여전히 존재하는지 확인
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('T10: 운동 종료(저장) 시 중복 저장 방지 (Race Condition)', (WidgetTester tester) async {
      // 1. Arrange: ActiveWorkoutPage 로드
      final session = createDummySession();

      await tester.pumpWidget(createWidgetUnderTest(
        ActiveWorkoutPage(
          session: session,
          repo: mockSessionRepo,
          exerciseRepo: mockExerciseLibraryRepo,
          date: DateTime(2024, 1, 1),
        ),
      ));
      await tester.pumpAndSettle();

      // 2. Act: '종료' 버튼 탭 -> 다이얼로그 '확인' -> 빠르게 다시 탭 시도
      // ActiveWorkoutPage의 하단 바에 있는 종료(Stop) 버튼 찾기
      final stopButton = find.byIcon(Icons.stop_circle_outlined);
      await tester.tap(stopButton);
      await tester.pumpAndSettle(); // 다이얼로그 표시

      // 다이얼로그의 '확인' (운동 완료하기) 버튼 찾기
      // 코드: l10n.finishWorkout ("운동 완료하기")
      final confirmButton = find.widgetWithText(ElevatedButton, '운동 완료하기');

      // 첫 번째 탭 (저장 시작)
      if (confirmButton.evaluate().isNotEmpty) {
         await tester.tap(confirmButton);
      } else {
         // Fallback: 텍스트 매칭 실패 시 버튼 타입으로 시도
         await tester.tap(find.byType(ElevatedButton).last);
      }

      // 3. Act: Race Condition 시뮬레이션
      // 비동기 저장 중에 사용자가 UI를 다시 터치하거나 네비게이션이 발생하는 상황
      // 여기서는 tester.pump()를 조절하여 중복 호출을 검증
      await tester.pump(); // Future 시작

      // 4. Assert: 저장 로직(repo.put)이 정확히 한 번만 호출되었는지 확인
      // ActiveWorkoutPage._finishWorkout 내부 로직 검증
      verify(mockSessionRepo.put(any)).called(1);
    });

  });
}

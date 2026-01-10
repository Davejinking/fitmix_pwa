import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants.dart';
import 'data/session_repo.dart';
import 'data/exercise_library_repo.dart';
import 'data/settings_repo.dart';
import 'data/auth_repo.dart';
import 'pages/login_page.dart';
import 'data/user_repo.dart';
import 'pages/splash_page.dart';
import 'pages/library_page_v2.dart';
import 'utils/dummy_data_generator.dart';
import 'models/session.dart';
import 'models/exercise_library.dart';
import 'services/exercise_seeding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  
  // Hive 초기화 및 어댑터 등록
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseLibraryItemAdapter());

  final sessionRepo = HiveSessionRepo();
  await sessionRepo.init();

  final exerciseRepo = HiveExerciseLibraryRepo();
  await exerciseRepo.init();

  final userRepo = HiveUserRepo();
  await userRepo.init();

  final settingsRepo = HiveSettingsRepo();
  await settingsRepo.init();

  final authRepo = GoogleAuthRepo();

  // 🏋️ Iron Log 운동 라이브러리 시딩
  try {
    final seedingService = ExerciseSeedingService();
    await seedingService.initializeAndSeed();
    
    // 시딩 통계 출력
    final stats = await seedingService.getStatistics();
    print('📊 Iron Log 운동 라이브러리: ${stats['total']}개 운동 로드 완료');
  } catch (e) {
    print('❌ 운동 라이브러리 시딩 실패: $e');
  }

  // 디버그 모드에서만 더미 데이터 생성
  if (kDebugMode) {
    try {
      // 강제로 더미 데이터 재생성 (테스트용)
      print('🗑️ 기존 운동 데이터 삭제 중...');
      await sessionRepo.clearAllData();
      
      print('🏋️ 최근 기록 테스트용 더미 데이터 생성 중...');
      await sessionRepo.seedDummyWorkoutData();
      
      // 생성 확인
      final newSessions = await sessionRepo.getWorkoutSessions();
      print('✅ 더미 데이터 생성 완료! (${newSessions.length}개 세션)');
      for (var session in newSessions) {
        final volume = session.totalVolume;
        print('  - ${session.ymd}: ${session.exercises.length}개 운동, 볼륨: ${volume.toStringAsFixed(0)}kg');
        for (var exercise in session.exercises) {
          print('    * ${exercise.name}: ${exercise.sets.length}세트');
        }
      }
    } catch (e) {
      print('❌ 더미 데이터 생성 실패: $e');
    }
  }

  // 사용자 프로필이 있는지 확인하여 첫 화면 결정
  final userProfile = await userRepo.getUserProfile();

  runApp(IronLogApp(
    sessionRepo: sessionRepo,
    exerciseRepo: exerciseRepo,
    userRepo: userRepo,
    settingsRepo: settingsRepo,
    authRepo: authRepo,
    isLoggedIn: userProfile != null,
  ));
}

class IronLogApp extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final UserRepo userRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;
  final bool isLoggedIn;
  const IronLogApp(
      {super.key,
      required this.sessionRepo,
      required this.exerciseRepo,
      required this.userRepo,
      required this.settingsRepo,
      required this.authRepo,
      required this.isLoggedIn});

  @override
  State<IronLogApp> createState() => _IronLogAppState();
}

class _IronLogAppState extends State<IronLogApp> {
  @override
  void initState() {
    super.initState();
    // 다크 모드로 고정, 테마 로드 불필요
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppConstants.darkTheme, // 다크 모드로 고정
      darkTheme: AppConstants.darkTheme,
      themeMode: ThemeMode.dark, // 항상 다크 모드
      locale: null, // 시스템 언어 자동 감지
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/library': (context) => LibraryPageV2(
          sessionRepo: widget.sessionRepo,
          exerciseRepo: widget.exerciseRepo,
        ),
      },
      home: kDebugMode
          // 디버그 모드: 로그인 여부와 상관없이 바로 SplashPage 진입
          ? SplashPage(
              sessionRepo: widget.sessionRepo,
              exerciseRepo: widget.exerciseRepo,
              userRepo: widget.userRepo,
              settingsRepo: widget.settingsRepo,
              authRepo: widget.authRepo,
            )
          // 릴리즈/프로파일 모드: 기존 로직 유지
          : (widget.isLoggedIn
              ? SplashPage(
                  sessionRepo: widget.sessionRepo,
                  exerciseRepo: widget.exerciseRepo,
                  userRepo: widget.userRepo,
                  settingsRepo: widget.settingsRepo,
                  authRepo: widget.authRepo,
                )
              : LoginPage(
                  sessionRepo: widget.sessionRepo,
                  exerciseRepo: widget.exerciseRepo,
                  userRepo: widget.userRepo,
                  settingsRepo: widget.settingsRepo,
                  authRepo: widget.authRepo,
                )),
    );
  }
}

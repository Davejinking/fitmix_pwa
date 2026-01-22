import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants.dart';
import 'core/iron_theme.dart';
import 'core/service_locator.dart';
import 'data/session_repo.dart';
import 'data/user_repo.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'pages/library_page_v2.dart';
import 'pages/analysis_page.dart';
import 'pages/big_three_detail_page.dart';
import 'pages/calendar_page.dart';
import 'widgets/exercise_log_card_demo.dart';
import 'widgets/workout_heatmap_demo.dart';
import 'pages/demo_calendar_screen.dart';
import 'pages/upgrade_page.dart';
import 'pages/goal_settings_page.dart';
import 'models/session.dart';
import 'models/exercise_library.dart';
import 'models/equipment.dart';
import 'services/exercise_seeding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  
  // .env 파일 로드 (없어도 앱 실행은 계속)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ .env file not found, using default placeholders.');
    }
  }

  // 🎯 Google AdMob 초기화
  await MobileAds.instance.initialize();
  if (kDebugMode) {
    print('💰 Google AdMob 초기화 완료');
  }
  
  // Hive 초기화 및 어댑터 등록
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(ExerciseLibraryItemAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(EquipmentAdapter());
  }

  // Service Locator 설정 (의존성 주입)
  await setupServiceLocator();

  // 🏋️ Iron Log 운동 라이브러리 시딩
  try {
    final seedingService = ExerciseSeedingService();
    await seedingService.initializeAndSeed();
    
    // 시딩 통계 출력 (디버그 모드만)
    if (kDebugMode) {
      final stats = await seedingService.getStatistics();
      print('📊 Iron Log 운동 라이브러리: ${stats['total']}개 운동 로드 완료');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ 운동 라이브러리 시딩 실패: $e');
    }
  }

  // 디버그 모드에서만 더미 데이터 생성
  if (kDebugMode) {
    try {
      final sessionRepo = getIt<SessionRepo>();
      
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
  final userRepo = getIt<UserRepo>();
  final userProfile = await userRepo.getUserProfile();

  runApp(IronLogApp(
    isLoggedIn: userProfile != null,
  ));
}

class IronLogApp extends StatefulWidget {
  final bool isLoggedIn;
  
  const IronLogApp({
    super.key,
    required this.isLoggedIn,
  });

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
      theme: IronTheme.darkTheme, // Iron 테마 적용
      darkTheme: IronTheme.darkTheme,
      themeMode: ThemeMode.dark, // 항상 다크 모드
      
      // 🌍 Bulletproof Localization Logic
      locale: null, // 시스템 언어 자동 감지
      supportedLocales: const [
        Locale('ko'), // 한국어 (기본값)
        Locale('ja'), // 일본어
        Locale('en'), // 영어
      ],
      
      // 🎯 Custom Locale Resolution Callback
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // 디버그 로깅 (디버그 모드만)
        if (kDebugMode) {
          print('🌐 Detected Device Locale: $deviceLocale');
        }
        
        // 기기 언어가 null인 경우 기본값 반환
        if (deviceLocale == null) {
          if (kDebugMode) {
            print('⚠️ Device locale is null, using default: ko');
          }
          return supportedLocales.first; // ko
        }
        
        // 기기 언어 코드가 지원 언어 목록에 있는지 확인
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == deviceLocale.languageCode) {
            if (kDebugMode) {
              print('✅ Matched locale: ${supportedLocale.languageCode}');
            }
            return supportedLocale;
          }
        }
        
        // 매칭되는 언어가 없으면 기본값(한국어) 반환
        if (kDebugMode) {
          print('⚠️ No match found, using default: ko');
        }
        return supportedLocales.first; // ko
      },
      
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/library': (context) => const LibraryPageV2(),
        '/analysis': (context) => const AnalysisPage(),
        '/big-three-detail': (context) => const BigThreeDetailPage(),
        '/calendar': (context) => const CalendarPage(),
        '/demo/exercise-log-card': (context) => const ExerciseLogCardDemo(),
        '/demo/workout-heatmap': (context) => const WorkoutHeatmapDemo(),
        '/demo/calendar': (context) => const DemoCalendarScreen(),
        '/upgrade': (context) => const UpgradePage(),
        '/goal_settings': (context) => const GoalSettingsPage(),
      },
      home: kDebugMode
          // 디버그 모드: 로그인 여부와 상관없이 바로 SplashPage 진입
          ? const SplashPage()
          // 릴리즈/프로파일 모드: 기존 로직 유지
          : (widget.isLoggedIn
              ? const SplashPage()
              : const LoginPage()),
    );
  }
}
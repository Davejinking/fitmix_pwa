import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants.dart';
import 'data/session_repo.dart';
import 'data/exercise_library_repo.dart';
import 'data/settings_repo.dart';
import 'data/auth_repo.dart';
import 'pages/login_page.dart';
import 'data/user_repo.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  Intl.defaultLocale = 'ko_KR';

  final sessionRepo = HiveSessionRepo();
  await sessionRepo.init();

  final exerciseRepo = HiveExerciseLibraryRepo();
  await exerciseRepo.init();

  final userRepo = HiveUserRepo();
  await userRepo.init();

  final settingsRepo = HiveSettingsRepo();
  await settingsRepo.init();

  final authRepo = GoogleAuthRepo();

  // 사용자 프로필이 있는지 확인하여 첫 화면 결정
  final userProfile = await userRepo.getUserProfile();

  runApp(FitMixApp(
    sessionRepo: sessionRepo,
    exerciseRepo: exerciseRepo,
    userRepo: userRepo,
    settingsRepo: settingsRepo,
    authRepo: authRepo,
    isLoggedIn: userProfile != null,
  ));
}

class FitMixApp extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final UserRepo userRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;
  final bool isLoggedIn;
  const FitMixApp(
      {super.key,
      required this.sessionRepo,
      required this.exerciseRepo,
      required this.userRepo,
      required this.settingsRepo,
      required this.authRepo,
      required this.isLoggedIn});

  @override
  State<FitMixApp> createState() => _FitMixAppState();
}

class _FitMixAppState extends State<FitMixApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeMode = await widget.settingsRepo.getThemeMode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppConstants.lightTheme,
      darkTheme: AppConstants.darkTheme,
      themeMode: _themeMode,
      locale: const Locale('ja', 'JP'), // 🔥 일본어 기본
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
      home: widget.isLoggedIn
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
            ),
    );
  }
}

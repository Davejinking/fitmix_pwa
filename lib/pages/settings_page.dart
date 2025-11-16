import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';
import '../data/exercise_library_repo.dart';
import '../data/user_repo.dart';
import '../data/session_repo.dart';
import '../data/auth_repo.dart';
import '../data/settings_repo.dart';
import '../main.dart';
import 'login_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SessionRepo sessionRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;

  const SettingsPage({
    super.key,
    required this.userRepo,
    required this.exerciseRepo,
    required this.sessionRepo,
    required this.settingsRepo,
    required this.authRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/ic_person.svg',
              width: 24,
              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
            title: const Text('프로필 정보 수정'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) =>
                    ProfilePage(userRepo: userRepo, authRepo: authRepo)),
              );
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/ic_theme.svg',
              width: 24,
              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
            title: const Text('화면 모드'),
            onTap: () async {
              var selectedThemeMode = await settingsRepo.getThemeMode();
              final newThemeMode = await showDialog<ThemeMode>(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    return RadioGroup<ThemeMode>(
                      onChanged: (value) {
                        if (value != null) setState(() => selectedThemeMode = value);
                      },
                      child: AlertDialog(
                        title: const Text('화면 모드 선택'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() => selectedThemeMode = ThemeMode.light);
                                Navigator.pop(context, ThemeMode.light);
                              },
                              child: RadioListTile<ThemeMode>(
                                title: const Text('라이트 모드'),
                                value: ThemeMode.light,
                                toggleable: selectedThemeMode == ThemeMode.light,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() => selectedThemeMode = ThemeMode.dark);
                                Navigator.pop(context, ThemeMode.dark);
                              },
                              child: RadioListTile<ThemeMode>(
                                title: const Text('다크 모드'),
                                value: ThemeMode.dark,
                                toggleable: selectedThemeMode == ThemeMode.dark,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() => selectedThemeMode = ThemeMode.system);
                                Navigator.pop(context, ThemeMode.system);
                              },
                              child: RadioListTile<ThemeMode>(
                                title: const Text('시스템 설정'),
                                value: ThemeMode.system,
                                toggleable: selectedThemeMode == ThemeMode.system,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
              if (newThemeMode != null) {
                await settingsRepo.saveThemeMode(newThemeMode);
                // 앱의 최상위 위젯을 다시 빌드하여 테마를 적용
                // context.findAncestorStateOfType<State<FitMixApp>>() 보다 안정적인 방식
                final state = context.findRootAncestorStateOfType<State<FitMixApp>>();
                (state as dynamic)._loadTheme();
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/ic_info.svg',
              width: 24,
              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
            title: const Text('앱 정보'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationIcon: const Icon(Icons.fitness_center),
                children: [
                  const Text('FitMix는 여러분의 건강한 운동 습관을 응원합니다.'),
                ],
              );
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/ic_logout.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await ErrorHandler.showConfirmDialog(
                context,
                '로그아웃',
                '정말 로그아웃 하시겠습니까?',
              );
              if (confirmed) {
                await authRepo.signOut();
                // 모든 사용자 데이터 삭제
                await userRepo.clearAllData();
                await sessionRepo.clearAllData();
                await exerciseRepo.clearAllData();
                await settingsRepo.clearAllData();

                if (context.mounted) {
                  // 로그인 화면으로 이동하고 이전의 모든 화면 기록을 삭제
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => LoginPage(
                            sessionRepo: sessionRepo,
                            exerciseRepo: exerciseRepo,
                            userRepo: userRepo,
                            settingsRepo: settingsRepo,
                            authRepo: authRepo)),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
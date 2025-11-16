import 'package:flutter/material.dart';
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

class SettingsPage extends StatefulWidget {
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await widget.settingsRepo.getThemeMode();
    if (mounted) {
      setState(() {
        _currentThemeMode = themeMode;
      });
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'システム';
      case ThemeMode.light:
        return 'ライト';
      case ThemeMode.dark:
        return 'ダーク';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('テーマ'),
            subtitle: Text(_getThemeModeLabel(_currentThemeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('プロフィール'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userRepo: widget.userRepo,
                    authRepo: widget.authRepo,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('バージョン'),
            subtitle: Text(AppConstants.appVersion),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

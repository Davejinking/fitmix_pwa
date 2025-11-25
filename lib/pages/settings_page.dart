import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../data/exercise_library_repo.dart';
import '../data/user_repo.dart';
import '../data/session_repo.dart';
import '../data/auth_repo.dart';
import '../data/settings_repo.dart';
import '../l10n/app_localizations.dart';
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

  String _getThemeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemSetting;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeLabel(_currentThemeMode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profile),
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
            title: Text(l10n.version),
            subtitle: Text(AppConstants.appVersion),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

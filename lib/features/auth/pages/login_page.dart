import 'package:flutter/material.dart';
import '../../../core/burn_fit_style.dart';
import '../../../core/service_locator.dart';
import '../../../data/exercise_library_repo.dart';
import '../../../data/session_repo.dart';
import '../../../data/settings_repo.dart';
import '../../../data/auth_repo.dart';
import '../../../data/user_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/pages/splash_page.dart';
import 'user_info_form_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _navigateToSplash(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SplashPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                // IRON LOG branding - Tactical Noir
                const Text(
                  'IRON LOG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 8.0,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '운동의 모든 것을 한 곳에서',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(flex: 3),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('게스트로 계속하기'),
                  onPressed: () async {
                    final userRepo = getIt<UserRepo>();
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UserInfoFormPage(userRepo: userRepo)),
                    );
                    if (result == true && context.mounted) {
                      _navigateToSplash(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: BurnFitStyle.darkGrayText,
                    backgroundColor: BurnFitStyle.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Text('G'), // Placeholder for Google Icon
                  label: Text(AppLocalizations.of(context).loginWithGoogle),
                  onPressed: () {
                    _setLoading(true);
                    final authRepo = getIt<AuthRepo>();
                    final userRepo = getIt<UserRepo>();
                    authRepo.signIn().then((account) async {
                      if (account != null) {
                        final profile = await userRepo.getUserProfile();
                        if (profile == null && mounted) {
                          final result = await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UserInfoFormPage(userRepo: userRepo)));
                          if (result == true) _navigateToSplash(context);
                        } else {
                          _navigateToSplash(context);
                        }
                      }
                    }).catchError((error) {
                      // Handle error, e.g., show a snackbar
                    }).whenComplete(() => _setLoading(false));
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: BurnFitStyle.white,
                      side: const BorderSide(color: BurnFitStyle.white),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

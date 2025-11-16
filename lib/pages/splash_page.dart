import 'package:flutter/material.dart';
import 'dart:async';
import '../core/burn_fit_style.dart';

import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/settings_repo.dart';
import '../data/auth_repo.dart';
import '../data/user_repo.dart';
import 'shell_page.dart';

class SplashPage extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final UserRepo userRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;
  const SplashPage(
      {super.key,
      required this.sessionRepo,
      required this.exerciseRepo,
      required this.userRepo,
      required this.settingsRepo, required this.authRepo});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // 3초 후 메인 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // pushReplacement를 사용하여 스플래시 화면으로 다시 돌아오지 못하게 함
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ShellPage(
              sessionRepo: widget.sessionRepo,
              exerciseRepo: widget.exerciseRepo,
              userRepo: widget.userRepo,
              settingsRepo: widget.settingsRepo,
              authRepo: widget.authRepo,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BurnFitStyle.primaryBlue.withValues(alpha: 0.8), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(Icons.fitness_center, size: 100, color: Colors.white),
                ),
                const SizedBox(height: 24),
                SlideTransition(
                  position: _slideAnimation,
                  child: const Text(
                    'FitMix',
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0),
                  ),
                ),
                const SizedBox(height: 12),
                SlideTransition(
                  position: _slideAnimation,
                  child: Text('오늘의 운동, 내일의 나를 만듭니다.',
                      style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
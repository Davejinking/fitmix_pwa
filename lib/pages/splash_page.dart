import 'package:flutter/material.dart';
import 'dart:async';

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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    // 2초 후 메인 화면으로 페이드 전환
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ShellPage(
              sessionRepo: widget.sessionRepo,
              exerciseRepo: widget.exerciseRepo,
              userRepo: widget.userRepo,
              settingsRepo: widget.settingsRepo,
              authRepo: widget.authRepo,
            ),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // 다크 모드 배경
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FitMix',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
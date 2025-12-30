import 'package:flutter/material.dart';
import '../data/session_repo.dart';
import '../data/auth_repo.dart';
import '../data/settings_repo.dart';
import '../data/user_repo.dart';
import '../data/exercise_library_repo.dart';
import '../core/l10n_extensions.dart';
import '../widgets/common/fm_bottom_nav.dart';
import 'analysis_page.dart';
import 'calendar_page.dart';
import 'home_page.dart';
import 'library_page_v2.dart';

class ShellPage extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final UserRepo userRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;

  const ShellPage({
    super.key,
    required this.sessionRepo,
    required this.exerciseRepo,
    required this.userRepo,
    required this.settingsRepo,
    required this.authRepo,
  });

  @override
  State<ShellPage> createState() => ShellPageState();
}

class ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  // IndexedStack을 사용하여 각 페이지의 상태를 보존
  late final List<Widget> _pages;

  // 라이브러리 탭으로 이동하는 메서드
  void navigateToLibrary({String? bodyPart}) {
    setState(() => _currentIndex = 2); // 라이브러리는 인덱스 2
    
    // 특정 부위가 지정된 경우, 해당 탭으로 이동
    if (bodyPart != null) {
      // LibraryPageV2에 부위 정보를 전달하는 로직은 나중에 구현
      // 현재는 라이브러리 탭으로만 이동
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        sessionRepo: widget.sessionRepo,
        userRepo: widget.userRepo,
        exerciseRepo: widget.exerciseRepo,
        settingsRepo: widget.settingsRepo,
        authRepo: widget.authRepo,
      ),
      CalendarPage(
        repo: widget.sessionRepo,
        exerciseRepo: widget.exerciseRepo,
      ),
      const LibraryPageV2(),
      AnalysisPage(
        repo: widget.sessionRepo,
        userRepo: widget.userRepo,
      ),
    ];
  }

  void onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // 다크 모드 배경 고정
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: FMBottomNav(
        currentIndex: _currentIndex,
        onTap: onItemTapped,
        items: [
          FMBottomNavItem(
            label: context.l10n.home,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          FMBottomNavItem(
            label: context.l10n.calendar,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
          ),
          FMBottomNavItem(
            label: context.l10n.library,
            icon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt,
          ),
          FMBottomNavItem(
            label: context.l10n.analysis,
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/session_repo.dart';
import '../data/auth_repo.dart';
import '../data/settings_repo.dart';
import '../data/user_repo.dart';
import '../data/exercise_library_repo.dart';
import '../core/burn_fit_style.dart';
import '../core/l10n_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'analysis_page.dart';
import 'calendar_page.dart';
import 'home_page.dart';
import 'library_page.dart';

class ShellPage extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final UserRepo userRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;

  const ShellPage(
      {super.key,
      required this.sessionRepo,
      required this.exerciseRepo,
      required this.userRepo,
      required this.settingsRepo, required this.authRepo});

  @override
  State<ShellPage> createState() => ShellPageState();
}

class ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  void onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 홈(0), 캘린더(1) 화면일 때는 AppBar를 숨겨서 자체 헤더를 사용하도록 함
      appBar: _currentIndex == 0 || _currentIndex == 1
          ? null
          : AppBar(
              title: Text(_getPageTitle(_currentIndex)),
            ),
      body: _getPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onItemTapped,
        // BURN FIT 디자인 시스템 색상 적용
        selectedItemColor: BurnFitStyle.primaryBlue,
        unselectedItemColor: BurnFitStyle.secondaryGrayText,
        // 선택 시 라벨 표시 여부
        showUnselectedLabels: true,
        // 아이템이 4개 이상일 때, 각 아이템의 배경 및 애니메이션 스타일을 고정
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavItem('assets/icons/ic_home.svg', context.l10n.home, 0),
          _buildNavItem('assets/icons/ic_calendar.svg', context.l10n.calendar, 1),
          _buildNavItem('assets/icons/ic_library.svg', context.l10n.library, 2),
          _buildNavItem('assets/icons/ic_analysis.svg', context.l10n.analysis, 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String svgPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        svgPath,
        width: 24,
        colorFilter: ColorFilter.mode(
          _currentIndex == index ? BurnFitStyle.primaryBlue : BurnFitStyle.secondaryGrayText,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }

  Widget _getPageContent() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
            sessionRepo: widget.sessionRepo,
            userRepo: widget.userRepo,
            exerciseRepo: widget.exerciseRepo,
            settingsRepo: widget.settingsRepo, 
            authRepo: widget.authRepo,
        );
      case 1:
        return CalendarPage(repo: widget.sessionRepo, exerciseRepo: widget.exerciseRepo);
      case 2:
        return LibraryPage(exerciseRepo: widget.exerciseRepo);
      case 3:
        return AnalysisPage(repo: widget.sessionRepo, userRepo: widget.userRepo);
      default:
        return Center(child: Text(context.l10n.unknownPage, style: const TextStyle(fontSize: 24)));
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0: return context.l10n.home;
      case 1: return context.l10n.calendar;
      case 2: return context.l10n.library;
      case 3: return context.l10n.analysis;
      default: return context.l10n.fitMix;
    }
  }
}

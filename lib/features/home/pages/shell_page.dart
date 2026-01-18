import 'package:flutter/material.dart';
import '../../../core/l10n_extensions.dart';
import '../../../core/iron_theme.dart';
import '../../../shared/widgets/common/iron_app_bar.dart';
import '../../../shared/widgets/common/fm_bottom_nav.dart';
import 'home_page.dart';
import '../../calendar/pages/calendar_page.dart';
import '../../library/pages/library_page.dart';
import '../../profile/pages/character_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => ShellPageState();
}

class ShellPageState extends State<ShellPage> {
  int _currentIndex = 0; // 홈 화면을 기본값으로 설정

  // IndexedStack을 사용하여 각 페이지의 상태를 보존
  late final List<Widget> _pages;
  
  // 🔥 HomePage의 GlobalKey
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  // 라이브러리 탭으로 이동하는 메서드
  void navigateToLibrary({String? bodyPart}) {
    setState(() => _currentIndex = 2); // 라이브러리는 인덱스 2
    
    // 특정 부위가 지정된 경우, 해당 탭으로 이동
    if (bodyPart != null) {
      // LibraryPage에 부위 정보를 전달하는 로직은 나중에 구현
      // 현재는 라이브러리 탭으로만 이동
    }
  }

  // 캘린더 탭으로 이동하는 메서드
  void navigateToCalendar() {
    setState(() => _currentIndex = 1); // 캘린더는 인덱스 1
    // 🔥 홈 화면 새로고침 (루틴 불러오기 후 홈으로 돌아올 때)
    _homePageKey.currentState?.refresh();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(key: _homePageKey), // 🔥 Key 추가
      const CalendarPage(),
      const Scaffold(
        appBar: IronAppBar(),
        backgroundColor: IronTheme.background,
        body: const LibraryPage(),
      ),
      const CharacterPage(), // Professional Profile Dashboard
    ];
  }

  void onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronTheme.background, // 다크 모드 배경 고정
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
            label: '프로필', // Professional Profile instead of Character
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }
}

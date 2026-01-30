import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import '../core/iron_theme.dart';
import '../widgets/common/iron_app_bar.dart';
import 'calendar_page_new.dart';
import 'home_page.dart';
import 'library_page_v2.dart';
import 'character_page.dart';

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
      // LibraryPageV2에 부위 정보를 전달하는 로직은 나중에 구현
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
      const CalendarPageNew(),
      const Scaffold(
        appBar: IronAppBar(),
        backgroundColor: IronTheme.background,
        body: LibraryPageV2(),
      ),
      const CharacterPage(), // Professional Profile Dashboard
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, action) => const CalendarPageNew(),
        closedElevation: 0,
        closedShape: const CircleBorder(),
        closedColor: const Color(0xFF007AFF),
        openColor: const Color(0xFF121212),
        middleColor: const Color(0xFF007AFF),
        closedBuilder: (context, action) {
          return FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              action();
            },
            backgroundColor: const Color(0xFF007AFF),
            elevation: 0,
            child: const Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              const SizedBox(width: 48), // SPACER for FAB
              _buildNavItem(Icons.fitness_center, 'Activity', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
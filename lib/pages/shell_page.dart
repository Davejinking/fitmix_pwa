import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import '../core/l10n_extensions.dart';
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

  void onItemTapped(int index) {
    // FAB 위치(index 2)는 건너뛰기
    if (index == 2) return;
    
    // index 3, 4는 실제로는 2, 3으로 매핑
    final actualIndex = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = actualIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, action) => const CalendarPageNew(),
        closedElevation: 0,
        closedShape: const CircleBorder(),
        closedColor: const Color(0xFF0D7FF2),
        openColor: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
        middleColor: const Color(0xFF0D7FF2),
        closedBuilder: (context, action) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D7FF2),
                  Color(0xFF0A5FBF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D7FF2).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                action();
              },
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xFF0F1419) : Colors.white,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: context.l10n.home,
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Search',
                index: 1,
                isDark: isDark,
              ),
              const SizedBox(width: 56), // FAB 공간
              _buildNavItem(
                icon: Icons.fitness_center,
                activeIcon: Icons.fitness_center,
                label: 'Activity',
                index: 3,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 4,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    // index 3, 4는 실제로는 2, 3으로 매핑
    final actualIndex = index > 2 ? index - 1 : index;
    final isActive = _currentIndex == actualIndex;
    
    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive 
                  ? const Color(0xFF0D7FF2)
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive 
                    ? const Color(0xFF0D7FF2)
                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
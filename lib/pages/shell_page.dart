import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'log_screen_v2.dart';
import 'home_page.dart';
import 'home_screen_v2.dart';
import 'library_page_v2.dart';
import 'profile_analytics_screen.dart';

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
    setState(() => _currentIndex = 3); // 프로필은 인덱스 3
  }

  // 캘린더 탭으로 이동하는 메서드 (Log Screen V2)
  void navigateToCalendar() {
    setState(() => _currentIndex = 2); // 캘린더는 인덱스 2
    // 🔥 홈 화면 새로고침 (루틴 불러오기 후 홈으로 돌아올 때)
    _homePageKey.currentState?.refresh();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      // 0: Home (New Dashboard)
      const HomeScreenV2(),
      HomePage(key: _homePageKey),     // 1: Search (Discovery feed)
      const LogScreenV2(),             // 2: Log (Tactical workout log)
      const ProfileAnalyticsScreen(),  // 3: Profile (Analytics Dashboard)
      Scaffold(                         // 4: Library (Exercise library - accessed via Start button)
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: const LibraryPageV2(),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
        elevation: 0,
        padding: EdgeInsets.zero,
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCompactNavItem(Icons.home, 'Home', 0),
            _buildCompactNavItem(Icons.search, 'Search', 1),
            _buildCenterInlineButton(),
            _buildCompactNavItem(Icons.calendar_today, 'Log', 2),
            _buildCompactNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterInlineButton() {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          // Navigate to Library tab (index 4)
          setState(() => _currentIndex = 4);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Start',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                size: 24,
              ),
              const SizedBox(height: 2),
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
      ),
    );
  }
}
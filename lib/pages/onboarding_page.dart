import 'package:flutter/material.dart';
import '../data/settings_repo.dart';

class OnboardingPage extends StatefulWidget {
  final SettingsRepo settingsRepo;
  final VoidCallback onComplete;

  const OnboardingPage({
    super.key,
    required this.settingsRepo,
    required this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.fitness_center,
      title: '운동을 기록하세요',
      subtitle: '세트, 무게, 횟수를 간편하게 기록하고\n운동 볼륨을 자동으로 계산해드려요',
      color: Color(0xFF007AFF),
    ),
    _OnboardingData(
      icon: Icons.music_note,
      title: '템포 가이드',
      subtitle: '정확한 템포로 운동하세요\n음성, 비프음, 진동으로 안내해드려요',
      color: Color(0xFFFF6B35),
    ),
    _OnboardingData(
      icon: Icons.local_fire_department,
      title: '스트릭을 쌓아가세요',
      subtitle: '매일 운동하고 연속 기록을 세워보세요\n꾸준함이 최고의 결과를 만들어요',
      color: Color(0xFF34C759),
    ),
    _OnboardingData(
      icon: Icons.insights,
      title: '성장을 확인하세요',
      subtitle: '주간, 월간 통계로 발전을 확인하고\n목표를 향해 나아가세요',
      color: Color(0xFFAF52DE),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await widget.settingsRepo.setOnboardingComplete(true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Skip 버튼
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // 페이지 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            // 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _pages[_currentPage].color
                          : const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          // 타이틀
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 서브타이틀
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFAAAAAA),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

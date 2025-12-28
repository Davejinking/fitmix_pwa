import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../models/gamification.dart';

class PowerShopPage extends StatefulWidget {
  final GamificationService gamificationService;
  const PowerShopPage({super.key, required this.gamificationService});

  @override
  State<PowerShopPage> createState() => _PowerShopPageState();
}

class _PowerShopPageState extends State<PowerShopPage> {
  late UserGameData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.gamificationService.data;
  }

  void _refresh() {
    setState(() => _data = widget.gamificationService.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('파워 상점', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('💪', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${_data.power}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('🛡️ 아이템'),
          _buildShopItem(
            icon: '❄️',
            title: '스트릭 프리즈',
            description: '하루 쉬어도 스트릭 유지',
            price: 50,
            owned: _data.freezes,
            onBuy: () async {
              if (await widget.gamificationService.buyFreeze()) {
                _refresh();
                _showSnackBar('스트릭 프리즈 구매 완료! ❄️');
              } else {
                _showSnackBar('파워가 부족해요 💪');
              }
            },
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            icon: '📊',
            title: '주간 운동 리포트',
            description: '이번 주 운동 분석 리포트',
            price: 30,
            onBuy: () {
              if (_data.power >= 30) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutReportPage(
                      gamificationService: widget.gamificationService,
                    ),
                  ),
                );
              } else {
                _showSnackBar('파워가 부족해요 💪');
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('🎨 커스터마이징 (준비 중)'),
          _buildShopItem(
            icon: '🌙',
            title: '다크 퍼플 테마',
            description: '보라색 포인트 테마',
            price: 100,
            locked: true,
            onBuy: () => _showSnackBar('준비 중이에요!'),
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            icon: '🔥',
            title: '파이어 테마',
            description: '불타는 오렌지 테마',
            price: 100,
            locked: true,
            onBuy: () => _showSnackBar('준비 중이에요!'),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('🏅 특별 뱃지 (준비 중)'),
          _buildShopItem(
            icon: '⚡',
            title: '번개 뱃지',
            description: '프로필에 표시되는 특별 뱃지',
            price: 200,
            locked: true,
            onBuy: () => _showSnackBar('준비 중이에요!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required String icon,
    required String title,
    required String description,
    required int price,
    int? owned,
    bool locked = false,
    required VoidCallback onBuy,
  }) {
    final canAfford = _data.power >= price && !locked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: locked ? null : Border.all(
          color: canAfford ? const Color(0xFFFF6B35).withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: locked ? const Color(0xFF2C2C2E) : const Color(0xFFFF6B35).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                locked ? '🔒' : icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: locked ? const Color(0xFF6A6A6A) : Colors.white,
                      ),
                    ),
                    if (owned != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '보유: $owned',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF34C759),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: locked ? const Color(0xFF4A4A4A) : const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          // 가격/구매 버튼
          GestureDetector(
            onTap: locked ? null : onBuy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: locked 
                    ? const Color(0xFF2C2C2E)
                    : canAfford 
                        ? const Color(0xFFFF6B35) 
                        : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💪', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: locked || !canAfford ? const Color(0xFF6A6A6A) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C2C2E),
      ),
    );
  }
}

// 운동 리포트 페이지
class WorkoutReportPage extends StatelessWidget {
  final GamificationService gamificationService;
  const WorkoutReportPage({super.key, required this.gamificationService});

  @override
  Widget build(BuildContext context) {
    final data = gamificationService.data;
    final league = data.league;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('📊 주간 리포트'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [league.color.withValues(alpha: 0.3), const Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(league.icon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    '${league.name} 리그',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: league.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${data.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 이번 주 통계
            const Text(
              '이번 주 성과',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('⚡', '${data.weeklyXP}', 'XP 획득'),
                const SizedBox(width: 12),
                _buildStatCard('💪', '${data.weeklyXP ~/ 100}', '파워 획득'),
              ],
            ),
            const SizedBox(height: 24),
            // 총 통계
            const Text(
              '전체 기록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('총 XP', '${data.totalXP} XP'),
            _buildInfoRow('현재 레벨', 'Level ${data.level}'),
            _buildInfoRow('보유 파워', '${data.power} 💪'),
            _buildInfoRow('스트릭 프리즈', '${data.freezes}개'),
            const SizedBox(height: 24),
            // 다음 목표
            const Text(
              '다음 목표',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${data.level + 1} 달성',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${data.xpToNextLevel} XP 남음',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (league.next != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(league.next!.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${league.next!.name} 리그 승급',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${league.next!.minXP - data.totalXP} XP 남음',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 응원 메시지
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF34C759).withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Text('💪', style: TextStyle(fontSize: 32)),
                  SizedBox(height: 8),
                  Text(
                    '잘하고 있어요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34C759),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '꾸준히 운동하면 목표를 달성할 수 있어요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFAAAAAA),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

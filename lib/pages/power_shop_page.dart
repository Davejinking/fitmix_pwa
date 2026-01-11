import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../models/gamification.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      // backgroundColor removed - uses theme default (pure black)
      appBar: AppBar(
        // backgroundColor removed - uses theme default
        title: Text(l10n.powerShop, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          _buildSectionTitle('🛡️ ${l10n.items}'),
          _buildShopItem(
            context: context,
            icon: '❄️',
            title: l10n.streakFreeze,
            description: l10n.streakFreezeDesc,
            price: 50,
            owned: _data.freezes,
            onBuy: () async {
              if (await widget.gamificationService.buyFreeze()) {
                _refresh();
                _showSnackBar(l10n.streakFreezeSuccess);
              } else {
                _showSnackBar(l10n.insufficientPower);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            context: context,
            icon: '📊',
            title: l10n.weeklyReport,
            description: l10n.weeklyReportDesc,
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
                _showSnackBar(l10n.insufficientPower);
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('🎨 ${l10n.customization} (${l10n.comingSoon})'),
          _buildShopItem(
            context: context,
            icon: '🌙',
            title: l10n.darkPurpleTheme,
            description: l10n.purplePointTheme,
            price: 100,
            locked: true,
            onBuy: () => _showSnackBar(l10n.comingSoonMessage),
          ),
          const SizedBox(height: 12),
          _buildShopItem(
            context: context,
            icon: '🔥',
            title: l10n.fireTheme,
            description: l10n.orangeTheme,
            price: 100,
            locked: true,
            onBuy: () => _showSnackBar(l10n.comingSoonMessage),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('🏅 ${l10n.specialBadges} (${l10n.comingSoon})'),
          _buildShopItem(
            context: context,
            icon: '⚡',
            title: l10n.lightningBadge,
            description: l10n.specialBadgeDesc,
            price: 200,
            locked: true,
            onBuy: () => _showSnackBar(l10n.comingSoonMessage),
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
    required BuildContext context,
    required String icon,
    required String title,
    required String description,
    required int price,
    int? owned,
    bool locked = false,
    required VoidCallback onBuy,
  }) {
    final l10n = AppLocalizations.of(context);
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
                          l10n.owned(owned),
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
    final l10n = AppLocalizations.of(context);
    final data = gamificationService.data;
    final league = data.league;

    return Scaffold(
      // backgroundColor removed - uses theme default (pure black)
      appBar: AppBar(
        // backgroundColor removed - uses theme default
        title: Text(l10n.weeklyReportTitle),
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
                    l10n.leaguePromotion(league.name),
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
            Text(
              l10n.thisWeekPerformance,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('⚡', '${data.weeklyXP}', l10n.xpEarned),
                const SizedBox(width: 12),
                _buildStatCard('💪', '${data.weeklyXP ~/ 100}', l10n.powerEarned),
              ],
            ),
            const SizedBox(height: 24),
            // 총 통계
            Text(
              l10n.totalRecords,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.totalXp, '${data.totalXP} XP'),
            _buildInfoRow(l10n.currentLevel, 'Level ${data.level}'),
            _buildInfoRow(l10n.currentPower, '${data.power} 💪'),
            _buildInfoRow(l10n.streakFreeze, '${data.freezes}개'),
            const SizedBox(height: 24),
            // 다음 목표
            Text(
              l10n.nextGoal,
              style: const TextStyle(
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
                              l10n.levelAchievement(data.level + 1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.xpRemaining(data.xpToNextLevel),
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
                                l10n.leaguePromotion(league.next!.name),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                l10n.xpRemaining(league.next!.minXP - data.totalXP),
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
              child: Column(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.encouragingMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34C759),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.encouragingDesc,
                    style: const TextStyle(
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

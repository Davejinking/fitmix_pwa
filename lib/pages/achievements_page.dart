import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../l10n/app_localizations.dart';

class AchievementsPage extends StatefulWidget {
  final AchievementService achievementService;
  const AchievementsPage({super.key, required this.achievementService});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  AchievementStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await widget.achievementService.calculateStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(l10n.achievement, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // 통계 요약
                SliverToBoxAdapter(child: _buildStatsCard(context)),
                // 업적 목록
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${l10n.achievement} (${widget.achievementService.unlockedIds.length}/${Achievements.all.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final achievement = Achievements.all[index];
                        final isUnlocked = widget.achievementService.isUnlocked(achievement.id);
                        return _buildAchievementTile(achievement, isUnlocked, context);
                      },
                      childCount: Achievements.all.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
              ],
            ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_stats == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🔥', '${_stats!.currentStreak}일', 'Current Streak'), // 임시로 영어 사용
              _buildStatItem('💪', '${_stats!.totalWorkouts}회', l10n.totalSets),
              _buildStatItem('🏋️', '${(_stats!.totalVolume / 1000).toStringAsFixed(0)}t', l10n.totalVolumeLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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
    );
  }

  Widget _buildAchievementTile(Achievement achievement, bool isUnlocked, BuildContext context) {
    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement, isUnlocked, context),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked 
              ? achievement.color.withValues(alpha: 0.15)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked 
              ? Border.all(color: achievement.color.withValues(alpha: 0.5), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              achievement.icon,
              size: 36,
              color: isUnlocked ? achievement.color : const Color(0xFF3A3A3C),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? Colors.white : const Color(0xFF6A6A6A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement, bool isUnlocked, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? achievement.color.withValues(alpha: 0.2)
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                achievement.icon,
                size: 40,
                color: isUnlocked ? achievement.color : const Color(0xFF6A6A6A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? const Color(0xFF34C759).withValues(alpha: 0.2)
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUnlocked ? l10n.completed : l10n.notCompleted,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? const Color(0xFF34C759) : const Color(0xFF6A6A6A),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

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
              _buildStatItem('🔥', '${_stats!.currentStreak}${l10n.dayUnit}', l10n.currentStreak),
              _buildStatItem('💪', '${_stats!.totalWorkouts}${l10n.repsUnit}', l10n.totalWorkouts),
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

  String _getAchievementTitle(Achievement achievement, AppLocalizations l10n) {
    final locale = l10n.localeName;
    
    switch (achievement.id) {
      case 'streak_3': 
        return locale == 'ja' ? '始まりが半分' : locale == 'en' ? 'Getting Started' : '시작이 반이다';
      case 'streak_7': 
        return locale == 'ja' ? '一週間戦士' : locale == 'en' ? 'Week Warrior' : '일주일 전사';
      case 'streak_30': 
        return locale == 'ja' ? '一ヶ月の奇跡' : locale == 'en' ? 'Monthly Miracle' : '한 달의 기적';
      case 'workout_1': 
        return locale == 'ja' ? '最初の一歩' : locale == 'en' ? 'First Step' : '첫 발걸음';
      case 'workout_10': 
        return locale == 'ja' ? '習慣形成' : locale == 'en' ? 'Habit Builder' : '습관 형성';
      case 'workout_50': 
        return locale == 'ja' ? '運動マニア' : locale == 'en' ? 'Fitness Enthusiast' : '운동 마니아';
      case 'workout_100': 
        return locale == 'ja' ? '百戦百勝' : locale == 'en' ? 'Hundred Club' : '백전백승';
      case 'volume_10k': 
        return locale == 'ja' ? '1万キログラム' : locale == 'en' ? 'Ten Thousand' : '만 킬로그램';
      case 'volume_100k': 
        return locale == 'ja' ? '10万クラブ' : locale == 'en' ? 'Hundred K Club' : '10만 클럽';
      case 'volume_1m': 
        return locale == 'ja' ? 'ミリオンリフター' : locale == 'en' ? 'Million Lifter' : '밀리언 리프터';
      case 'weekend_warrior': 
        return locale == 'ja' ? '週末戦士' : locale == 'en' ? 'Weekend Warrior' : '주말 전사';
      default: return achievement.title;
    }
  }

  String _getAchievementDescription(Achievement achievement, AppLocalizations l10n) {
    final locale = l10n.localeName;
    
    switch (achievement.id) {
      case 'streak_3': 
        return locale == 'ja' ? '3日連続運動' : locale == 'en' ? '3 days workout streak' : '3일 연속 운동';
      case 'streak_7': 
        return locale == 'ja' ? '7日連続運動' : locale == 'en' ? '7 days workout streak' : '7일 연속 운동';
      case 'streak_30': 
        return locale == 'ja' ? '30日連続運動' : locale == 'en' ? '30 days workout streak' : '30일 연속 운동';
      case 'workout_1': 
        return locale == 'ja' ? '初回運動完了' : locale == 'en' ? 'Complete first workout' : '첫 운동 완료';
      case 'workout_10': 
        return locale == 'ja' ? '10回運動完了' : locale == 'en' ? 'Complete 10 workouts' : '10회 운동 완료';
      case 'workout_50': 
        return locale == 'ja' ? '50回運동完了' : locale == 'en' ? 'Complete 50 workouts' : '50회 운동 완료';
      case 'workout_100': 
        return locale == 'ja' ? '100回運동完了' : locale == 'en' ? 'Complete 100 workouts' : '100회 운동 완료';
      case 'volume_10k': 
        return locale == 'ja' ? '総ボリューム10,000kg達成' : locale == 'en' ? 'Reach 10,000kg total volume' : '총 볼륨 10,000kg 달성';
      case 'volume_100k': 
        return locale == 'ja' ? '総ボリューム100,000kg達成' : locale == 'en' ? 'Reach 100,000kg total volume' : '총 볼륨 100,000kg 달성';
      case 'volume_1m': 
        return locale == 'ja' ? '総ボリューム1,000,000kg達성' : locale == 'en' ? 'Reach 1,000,000kg total volume' : '총 볼륨 1,000,000kg 달성';
      case 'weekend_warrior': 
        return locale == 'ja' ? '週末に運動' : locale == 'en' ? 'Workout on weekend' : '주말에 운동하기';
      default: return achievement.description;
    }
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
                _getAchievementTitle(achievement, AppLocalizations.of(context)),
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
              _getAchievementTitle(achievement, l10n),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getAchievementDescription(achievement, l10n),
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
                isUnlocked ? l10n.achievementUnlocked : l10n.achievementLocked,
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

import 'package:flutter/material.dart';
import '../../../core/service_locator.dart';
import '../../../data/session_repo.dart';
import '../../../data/user_repo.dart';
import '../../../models/session.dart';
import '../../../core/iron_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/workout_heatmap.dart';
import '../../../widgets/common/iron_app_bar.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late SessionRepo repo;
  late UserRepo userRepo;
  Map<DateTime, double> workoutData = {};
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    repo = getIt<SessionRepo>();
    userRepo = getIt<UserRepo>();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => isLoading = true);
    
    try {
      final sessions = await repo.getWorkoutSessions();
      final data = <DateTime, double>{};
      
      for (var session in sessions) {
        final date = repo.ymdToDateTime(session.ymd);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        data[normalizedDate] = session.totalVolume;
      }
      
      setState(() {
        workoutData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: IronTheme.background,
      appBar: const IronAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heatmap Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.workoutConsistency.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.activityPastMonths(6),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          WorkoutHeatmap(
                            workoutData: workoutData,
                            monthsToShow: 6,
                            onDayTap: (date) {
                              // Navigate to that day's workout
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Workout on ${date.toString().split(' ')[0]}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Stats Summary
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildStatsSummary(),
                          ),
                          const SizedBox(height: 32),
                          // Additional analysis sections
                          _buildComingSoonSections(context),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatsSummary() {
    final l10n = AppLocalizations.of(context);
    final totalWorkouts = workoutData.values.where((v) => v > 0).length;
    final totalVolume = workoutData.values.fold(0.0, (sum, v) => sum + v);
    final avgVolume = totalWorkouts > 0 ? totalVolume / totalWorkouts : 0;
    
    // Calculate current streak
    int currentStreak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (workoutData.containsKey(normalizedDate) && workoutData[normalizedDate]! > 0) {
        currentStreak++;
      } else if (i > 0) {
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('WORKOUTS', '$totalWorkouts'),
              _buildDivider(),
              _buildStatItem('TOTAL VOL', '${(totalVolume / 1000).toStringAsFixed(1)}t'),
              _buildDivider(),
              _buildStatItem('AVG VOL', '${(avgVolume / 1000).toStringAsFixed(1)}t'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFF2C2C2E)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF6B35),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dayStreak(currentStreak),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFF2C2C2E),
    );
  }

  Widget _buildComingSoonSections(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MORE INSIGHTS COMING SOON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildComingSoonCard('Body Part Analysis', Icons.accessibility_new),
          const SizedBox(height: 12),
          _buildComingSoonCard('Progress Tracking', Icons.trending_up),
          const SizedBox(height: 12),
          _buildComingSoonCard('Personal Records', Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SOON',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
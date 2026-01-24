import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../models/session.dart';
import '../models/exercise_db.dart';
import '../l10n/app_localizations.dart';
import 'shell_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SessionRepo sessionRepo;
  late UserRepo userRepo;

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sessionRepo = getIt<SessionRepo>();
    userRepo = getIt<UserRepo>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOperationalStatus(),
                      const SizedBox(height: 24),
                      _buildWeeklyCalendar(),
                      const SizedBox(height: 24),
                      _buildStatsCards(),
                      const SizedBox(height: 16),
                      _buildMetricsRow(),
                      const SizedBox(height: 32),
                      _buildLatestLogs(),
                      const SizedBox(height: 24),
                      _buildStartWorkoutButton(),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3F3F46), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          Row(
            children: const [
              Text(
                'IRON',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontFamily: 'Courier',
                ),
              ),
              SizedBox(width: 8),
              Text(
                'LOG',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                  letterSpacing: 2.0,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3F3F46), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white, size: 20),
              onPressed: () {
                final shellState = context.findAncestorStateOfType<ShellPageState>();
                shellState?.onItemTapped(3);
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalStatus() {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    
    // Detect if using Asian language for letter spacing
    final isAsianLanguage = l10n.localeName != 'en';
    final letterSpacing = isAsianLanguage ? 0.5 : 2.0;
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${l10n.operationalStatus} / ${l10n.weekLabel} $weekNumber ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF71717A),
              fontFamily: 'Courier',
              letterSpacing: letterSpacing,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: const Text(
            'LIVE_SYNC',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
              fontFamily: 'Courier',
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    // Get localized weekday labels
    final dayLabels = [
      l10n.weekdayMonAbbr,
      l10n.weekdayTueAbbr,
      l10n.weekdayWedAbbr,
      l10n.weekdayThuAbbr,
      l10n.weekdayFriAbbr,
      l10n.weekdaySatAbbr,
      l10n.weekdaySunAbbr,
    ];
    
    return FutureBuilder<Set<String>>(
      future: _getWorkoutDates(),
      builder: (context, snapshot) {
        final workoutDates = snapshot.data ?? <String>{};
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A), width: 1),
            color: const Color(0xFF18181B).withValues(alpha: 0.5),
          ),
          child: Row(
            children: weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final isToday = date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
              final dateYmd = sessionRepo.ymd(date);
              final hasWorkout = workoutDates.contains(dateYmd);
              final dayLabel = dayLabels[date.weekday - 1];

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF27272A).withValues(alpha: 0.8) : Colors.transparent,
                    border: Border(
                      right: index < 6 
                          ? const BorderSide(color: Color(0xFF27272A), width: 1)
                          : BorderSide.none,
                    ),
                  ),
                  child: _buildDayColumn(dayLabel, hasWorkout, isToday, locale),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDayColumn(String label, bool completed, bool isToday, String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: isToday ? const Color(0xFF2563EB) : const Color(0xFF71717A),
              fontFamily: 'Courier',
              letterSpacing: locale == 'en' ? 0.5 : 0.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF2563EB) : Colors.transparent,
              border: Border.all(
                color: isToday ? const Color(0xFF2563EB) : const Color(0xFF3F3F46),
                width: isToday ? 2 : 1,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : (isToday
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final l10n = AppLocalizations.of(context);
    final isAsianLanguage = l10n.localeName != 'en';
    final letterSpacing = isAsianLanguage ? 0.5 : 2.0;
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _getWeeklyStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {
          'totalLoad': 295.0,
          'loadChange': 12.5,
          'volume': 12.3,
        };

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.totalLoad,
                '${stats['totalLoad']?.toInt() ?? 0}',
                'KG',
                Icons.fitness_center,
                '+${stats['loadChange']?.toStringAsFixed(1) ?? 0}% ${l10n.vsLast}',
                letterSpacing,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.volume,
                '${stats['volume']?.toStringAsFixed(1) ?? 0}',
                'TON',
                Icons.bar_chart,
                l10n.sessionAvg,
                letterSpacing,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, String subtitle, double letterSpacing) {
    final isPercentage = subtitle.contains('%');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border.all(color: const Color(0xFF27272A), width: 1),
      ),
      child: Stack(
        children: [
          // Icon in top right
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              icon,
              color: const Color(0xFF3F3F46),
              size: 32,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF71717A),
                  fontFamily: 'Courier',
                  letterSpacing: letterSpacing,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontFamily: 'Courier',
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isPercentage ? const Color(0xFF2563EB) : const Color(0xFF52525B),
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    final l10n = AppLocalizations.of(context);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSessionMetrics(),
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? {
          'hr': 142,
          'duration': '01:12',
          'restTime': 90,
        };

        return Row(
          children: [
            Expanded(
              child: _buildSmallMetricCard('${l10n.heartRate} / BPM', '${metrics['hr']}', '~'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallMetricCard(l10n.duration, metrics['duration'] ?? '00:00', ''),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallMetricCard(l10n.restTime, '${metrics['restTime']}', 'SEC'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallMetricCard(String label, String value, String suffix) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border.all(color: const Color(0xFF27272A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF71717A),
              fontFamily: 'Courier',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontFamily: 'Courier',
                  height: 1.0,
                ),
              ),
              if (suffix.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF71717A),
                    fontFamily: 'Courier',
                  ),
                ),
              ],
              if (label.contains('HR'))
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.show_chart,
                    color: Color(0xFF2563EB),
                    size: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestLogs() {
    final l10n = AppLocalizations.of(context);
    final isAsianLanguage = l10n.localeName != 'en';
    final letterSpacing = isAsianLanguage ? 0.5 : 2.0;
    
    return FutureBuilder<List<Session>>(
      future: _getLatestSessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.latestLogs,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF71717A),
                fontFamily: 'Courier',
                letterSpacing: letterSpacing,
              ),
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    l10n.noRecentWorkouts,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                      fontFamily: 'Courier',
                      letterSpacing: isAsianLanguage ? 0.5 : 1.5,
                    ),
                  ),
                ),
              )
            else
              ...sessions.take(2).map((session) => _buildLogCard(session)),
          ],
        );
      },
    );
  }

  Widget _buildLogCard(Session session) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    final date = DateTime.parse(session.ymd);
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);
    final formattedTime = '18:30'; // Placeholder
    
    // Get localized exercise names
    String workoutName;
    if (session.routineName != null && session.routineName!.isNotEmpty) {
      workoutName = session.routineName!;
    } else if (session.exercises.isNotEmpty) {
      // Get localized names for exercises
      final exerciseNames = session.exercises.map((e) {
        // Try to get localized name from ExerciseDB
        try {
          final localizedName = ExerciseDB.getExerciseNameLocalized(e.name, locale);
          return localizedName;
        } catch (_) {
          // Fallback to original name if localization fails
          return e.name.replaceAll('_', ' ');
        }
      }).toList();
      workoutName = exerciseNames.join(' + ');
    } else {
      workoutName = 'WORKOUT SESSION';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFF18181B), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale == 'en' ? workoutName.toUpperCase() : workoutName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Courier',
                    letterSpacing: locale == 'en' ? 1.5 : 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate // $formattedTime',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF52525B),
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF3F3F46),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildStartWorkoutButton() {
    final l10n = AppLocalizations.of(context);
    final isAsianLanguage = l10n.localeName != 'en';
    final letterSpacing = isAsianLanguage ? 1.0 : 3.0;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () {
              final shellState = context.findAncestorStateOfType<ShellPageState>();
              shellState?.navigateToCalendar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 16),
                Text(
                  l10n.startSession,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: letterSpacing,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.systemReady}',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF3F3F46),
                fontFamily: 'Courier',
                letterSpacing: 2.0,
              ),
            ),
            const Text(
              'SYS_TEMP: 34°C',
              style: TextStyle(
                fontSize: 8,
                color: Color(0xFF3F3F46),
                fontFamily: 'Courier',
                letterSpacing: 2.0,
              ),
            ),
            const Text(
              'LON: 74.0060 W',
              style: TextStyle(
                fontSize: 8,
                color: Color(0xFF3F3F46),
                fontFamily: 'Courier',
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  Future<Set<String>> _getWorkoutDates() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    return sessions.map((s) => s.ymd).toSet();
  }

  Future<List<Session>> _getLatestSessions() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    sessions.sort((a, b) => b.ymd.compareTo(a.ymd));
    return sessions.take(5).toList();
  }

  Future<Map<String, dynamic>> _getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final sessions = await sessionRepo.getSessionsInRange(startOfWeek, endOfWeek);
    final workoutSessions = sessions.where((s) => s.isWorkoutDay).toList();
    
    double totalLoad = 0;
    double totalVolume = 0;
    
    for (var session in workoutSessions) {
      for (var exercise in session.exercises) {
        for (var set in exercise.sets) {
          final load = set.weight;
          final volume = set.weight * set.reps;
          if (load > totalLoad) totalLoad = load;
          totalVolume += volume;
        }
      }
    }
    
    // Get previous week for comparison
    final prevStartOfWeek = startOfWeek.subtract(const Duration(days: 7));
    final prevEndOfWeek = prevStartOfWeek.add(const Duration(days: 6));
    final prevSessions = await sessionRepo.getSessionsInRange(prevStartOfWeek, prevEndOfWeek);
    final prevWorkoutSessions = prevSessions.where((s) => s.isWorkoutDay).toList();
    
    double prevTotalLoad = 0;
    for (var session in prevWorkoutSessions) {
      for (var exercise in session.exercises) {
        for (var set in exercise.sets) {
          if (set.weight > prevTotalLoad) prevTotalLoad = set.weight;
        }
      }
    }
    
    final loadChange = prevTotalLoad > 0 
        ? ((totalLoad - prevTotalLoad) / prevTotalLoad) * 100 
        : 0.0;
    
    return {
      'totalLoad': totalLoad,
      'loadChange': loadChange,
      'volume': totalVolume / 1000, // Convert to tons
    };
  }

  Future<Map<String, dynamic>> _getSessionMetrics() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    if (sessions.isEmpty) {
      return {
        'hr': 142,
        'duration': '00:00',
        'restTime': 90,
      };
    }
    
    final latestSession = sessions.reduce((a, b) => 
      a.ymd.compareTo(b.ymd) > 0 ? a : b
    );
    
    final durationMinutes = latestSession.durationInSeconds ~/ 60;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    return {
      'hr': 142, // Placeholder - would need heart rate data
      'duration': '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
      'restTime': 90, // Placeholder - would need rest time tracking
    };
  }
}

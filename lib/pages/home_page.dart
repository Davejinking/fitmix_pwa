import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFF000000), // Pure Black
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20), // Consistent horizontal padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // --- [ 1. DASHBOARD AREA - Grouped Surface ] ---
                    Container(
                      padding: const EdgeInsets.all(16), // Reduced from 20 for tighter feel
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A), // Slightly lighter background
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1), // Subtle border
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OPERATOR STATUS',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildOperationalStatus(),
                          const SizedBox(height: 12),
                          _buildWeeklyCalendar(),
                          const SizedBox(height: 16),
                          _buildStatsCards(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32), // Reduced from 52 (40% reduction)
                    
                    // --- [ 2. ACTION AREA ] ---
                    _buildQuickActions(),
                    const SizedBox(height: 32), // Reduced from 52 (40% reduction)
                    
                    // --- [ 3. QUICK DEPLOY ] ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUICK DEPLOY',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.grey[800], size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // 가로 슬라이더
                    SizedBox(
                      height: 120, // Increased from 110 for more substantial feel
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 40),
                        clipBehavior: Clip.none,
                        children: [
                          _buildAddRoutineCard(),
                          const SizedBox(width: 12),
                          _buildRoutineQuickCard('PUSH A', 'CHEST/TRI', true),
                          const SizedBox(width: 12),
                          _buildRoutineQuickCard('PULL B', 'BACK/BI', false),
                          const SizedBox(width: 12),
                          _buildRoutineQuickCard('LEGS', 'SQUAT FOCUS', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- [ 4. SESSION START ] ---
                    _buildInitiateSessionButton(),
                    const SizedBox(height: 32),
                    
                    // --- [ 5. RECENT LOGS ] ---
                    const Text(
                      'RECENT LOGS',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLatestLogs(),
                    const SizedBox(height: 40),
                  ],
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF121212), // Subtle surface, no border
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.asMap().entries.map((entry) {
              final date = entry.value;
              final isToday = date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
              final dateYmd = sessionRepo.ymd(date);
              final hasWorkout = workoutDates.contains(dateYmd);
              final dayLabel = dayLabels[date.weekday - 1];

              return _buildDayIndicator(dayLabel, hasWorkout, isToday, locale);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDayIndicator(String label, bool completed, bool isToday, String locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isToday ? const Color(0xFF007AFF) : const Color(0xFF666666),
            letterSpacing: locale == 'en' ? 0.5 : 0.0,
          ),
        ),
        const SizedBox(height: 8),
        // Centered minimal indicator
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: completed 
                ? const Color(0xFF007AFF) 
                : (isToday ? const Color(0xFF007AFF).withValues(alpha: 0.3) : Colors.transparent),
            shape: BoxShape.circle,
            border: isToday && !completed
                ? Border.all(color: const Color(0xFF007AFF), width: 1.5)
                : null,
          ),
        ),
      ],
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
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Watermark icon in background with very low opacity
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.05),
              size: 60,
            ),
          ),
          // All content aligned to left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888),
                  letterSpacing: letterSpacing,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFFFFF),
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPercentage ? const Color(0xFF007AFF) : const Color(0xFF555555),
                  letterSpacing: 0.5,
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

  // 퀵 액션 버튼들 (심플하고 작게)
  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Perfect spacing across width
      children: [
        _buildQuickActionIcon(Icons.fitness_center, l10n.quickActionRoutine, () {}),
        _buildQuickActionIcon(Icons.code, l10n.quickActionProgram, () {}),
        _buildQuickActionIcon(Icons.edit_calendar, l10n.quickActionPlan, () {}),
        _buildQuickActionIcon(Icons.timer, l10n.quickActionRest, () {}),
        _buildQuickActionIcon(Icons.edit_note, l10n.quickActionLog, () {}),
      ],
    );
  }

  Widget _buildQuickActionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A), // Higher contrast
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25), // More visible
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF888888), // Higher contrast
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 [1] TRIGGER: INITIATE SESSION - Critical action with electric blue
  Widget _buildInitiateSessionButton() {
    final l10n = AppLocalizations.of(context);
    
    return InkWell(
      onTap: () {
        // 빈 세션 시작 (Free Workout)
        final shellState = context.findAncestorStateOfType<ShellPageState>();
        shellState?.navigateToCalendar();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF), // Solid electric blue for critical action
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.startSession.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Routine Quick Card with haptic feedback and scale transition
  Widget _buildRoutineQuickCard(String title, String subtitle, bool isFavorite) {
    return Material(
      color: const Color(0xFF121212),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // Haptic feedback
          HapticFeedback.lightImpact();
          // Load routine
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFavorite 
                    ? const Color(0xFF007AFF) 
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: isFavorite ? [
                BoxShadow(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFFB3B3B3),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isFavorite)
                      const Icon(Icons.star, color: Color(0xFF007AFF), size: 14),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '6 exercises',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2d ago',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add Routine Card with haptic feedback and scale transition
  Widget _buildAddRoutineCard() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // Haptic feedback
          HapticFeedback.lightImpact();
          // Navigate to create routine
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: Colors.grey.withValues(alpha: 0.4),
              strokeWidth: 2,
              dashWidth: 6,
              dashSpace: 4,
              borderRadius: 16,
            ),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.grey[500], size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'ADD\nROUTINE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dashedPath.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

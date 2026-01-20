import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../data/settings_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/auth_repo.dart';
import '../data/routine_repo.dart';
import '../core/l10n_extensions.dart';
import '../core/iron_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'shell_page.dart';
import '../models/session.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import 'achievements_page.dart';
import '../widgets/common/iron_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState(); // 🔥 public으로 변경
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin { // 🔥 public으로 변경
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  
  // GetIt으로 가져온 repositories를 저장할 변수들
  late SessionRepo sessionRepo;
  late UserRepo userRepo;
  late ExerciseLibraryRepo exerciseRepo;
  late SettingsRepo settingsRepo;
  late AuthRepo authRepo;
  late RoutineRepo routineRepo;

  // 🔥 새로고침을 위한 키
  int _refreshKey = 0;

  // 🔥 외부에서 호출 가능한 refresh 메서드
  void refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // GetIt에서 repositories 가져오기
    sessionRepo = getIt<SessionRepo>();
    userRepo = getIt<UserRepo>();
    exerciseRepo = getIt<ExerciseLibraryRepo>();
    settingsRepo = getIt<SettingsRepo>();
    authRepo = getIt<AuthRepo>();
    routineRepo = getIt<RoutineRepo>();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final cardCount = 6; // XP + 스트릭 + 오늘 요약 + 업적 + 목표 + 트렌드
    _slideAnimations = List.generate(cardCount, (index) {
      final start = 0.15 * index;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronTheme.background,
      appBar: IronAppBar(
        actions: [
          // Demo 버튼 (디버그 모드에서만 표시)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            PopupMenuButton<String>(
              icon: Icon(Icons.science_outlined, color: IronTheme.textHigh),
              tooltip: 'Demo Pages',
              onSelected: (value) {
                Navigator.pushNamed(context, value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: '/demo/exercise-log-card',
                  child: Text('Exercise Log Card'),
                ),
                const PopupMenuItem(
                  value: '/demo/workout-heatmap',
                  child: Text('Workout Heatmap'),
                ),
                const PopupMenuItem(
                  value: '/demo/calendar',
                  child: Text('Monochrome Calendar'),
                ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: IronTheme.textHigh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // DELETED: Level/XP/Streak section (gamification removed)
              
              // Weekly Status Module (Wireframe HUD)
              SlideTransition(
                position: _slideAnimations[0],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildWeeklyCalendar(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Today's Plan Module (Wireframe HUD)
              SlideTransition(
                position: _slideAnimations[1],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildMainActionCard(),
                ),
              ),
              const SizedBox(height: 8),
              
              // 🎯 Performance Widgets (Side by Side) - Tactical HUD Style
              SlideTransition(
                position: _slideAnimations[2],
                child: FadeTransition(
                  opacity: _animationController,
                  child: Row(
                    children: [
                      Expanded(
                        child: _HomeBigThreeWidget(sessionRepo: sessionRepo),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeVolumeWidget(sessionRepo: sessionRepo),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Monthly Goal Module (Wireframe HUD)
              SlideTransition(
                position: _slideAnimations[3],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildGoalProgress(),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 메인 액션 (오늘의 운동 시작) - 단일 버튼!
  Widget _buildMainActionCard() {
    return FutureBuilder<Session?>(
      key: ValueKey('main_action_$_refreshKey'), // 🔥 refreshKey 사용
      future: _getTodaySession(),
      builder: (context, snapshot) {
        final todaySession = snapshot.data;
        final hasPlan = todaySession != null && 
                       todaySession.isWorkoutDay && 
                       todaySession.exercises.isNotEmpty;
        final isRest = todaySession?.isRest ?? false;
        final isCompleted = todaySession?.isCompleted ?? false;

        if (isRest) {
          return Column(
            children: [
              const SizedBox(height: 60),
              // Status (영어 고정 - Design Element)
              const Text(
                'STATUS: RESTING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF616161), // Colors.grey[700]
                  fontFamily: 'Courier',
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 60),
            ],
          );
        }

        if (!hasPlan) {
          return Column(
            children: [
              const SizedBox(height: 60),
              // Status text - minimalist (영어 고정 - Design Element)
              const Text(
                'NO ACTIVE SESSION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF616161), // Colors.grey[700]
                  fontFamily: 'Courier',
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 40),
              // Ghost button - transparent
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final shellState = context.findAncestorStateOfType<ShellPageState>();
                    shellState?.navigateToCalendar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Solid Grey[200]
                    foregroundColor: Colors.black, // Black text
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    context.l10n.initiateWorkout,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          );
        }

        // Has plan - display simple, honest info
        final exerciseCount = todaySession.exercises.length;
        final completedCount = todaySession.exercises.where((e) => 
          e.sets.isNotEmpty && e.sets.every((s) => s.isCompleted)).length;
        
        // Display routine name if available, otherwise "FREESTYLE"
        final displayTitle = todaySession.routineName?.toUpperCase() ?? 'FREESTYLE';
        
        print('🔍 [HOME] Session ymd: ${todaySession.ymd}');
        print('🔍 [HOME] Session routineName: ${todaySession.routineName}');
        print('🔍 [HOME] Display title: $displayTitle');
        print('🔍 [HOME] Exercise count: $exerciseCount');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Status (영어 고정 - Design Element)
            Text(
              isCompleted ? 'SESSION COMPLETE' : 'SESSION READY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isCompleted ? Colors.white : const Color(0xFF616161), // Colors.grey[700]
                fontFamily: 'Courier',
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            // Routine Name (Dynamic!)
            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            // Exercise counter (Tactical Style)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // Big Number
                Text(
                  '$completedCount / $exerciseCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8),
                // Small Label (영어 고정 - Design Element)
                const Text(
                  'EXERCISES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF616161), // Colors.grey[700]
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Ghost button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  final shellState = context.findAncestorStateOfType<ShellPageState>();
                  shellState?.navigateToCalendar();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isCompleted ? context.l10n.editSession : context.l10n.startSession,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        );
      },
    );
  }

  // Weekly Status - Dynamic with Today Highlight
  Widget _buildWeeklyCalendar() {
    return FutureBuilder<Set<String>>(
      future: _getWorkoutDates(),
      builder: (context, snapshot) {
        final workoutDates = snapshot.data ?? <String>{};
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        
        // Generate current week dates (Mon-Sun)
        final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Clickable Title Row
            GestureDetector(
              onTap: () {
                print('🎯 Navigating to Analysis');
                Navigator.pushNamed(context, '/analysis');
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    const Text(
                      'WEEKLY STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF616161), // Colors.grey[700]
                        fontFamily: 'Courier',
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 🎯 Chevron hint for clickability
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
            // Day Labels + Dots - Dynamic
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((date) {
                // Check if this is TODAY
                final isToday = date.year == now.year && 
                                date.month == now.month && 
                                date.day == now.day;
                
                // Check workout status
                final dateYmd = sessionRepo.ymd(date);
                final hasWorkout = workoutDates.contains(dateYmd);
                
                // Day label - Localized
                final dayLabels = [
                  context.l10n.weekdayMonShort,
                  context.l10n.weekdayTueShort,
                  context.l10n.weekdayWedShort,
                  context.l10n.weekdayThuShort,
                  context.l10n.weekdayFriShort,
                  context.l10n.weekdaySatShort,
                  context.l10n.weekdaySunShort,
                ];
                final dayLabel = dayLabels[date.weekday - 1];
                
                return Column(
                  children: [
                    // A. Day Label (Highlight TODAY)
                    SizedBox(
                      width: 12,
                      child: Text(
                        dayLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                          color: isToday ? Colors.white : Colors.grey[700],
                          fontFamily: 'Courier',
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // B. Status Chip (Rounded Square)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        // Solid white for workout, hollow for inactive
                        color: hasWorkout ? Colors.white : Colors.transparent,
                        // Border for hollow look (inactive days)
                        border: hasWorkout ? null : Border.all(
                          color: Colors.white.withValues(alpha: 0.3), 
                          width: 1.0,
                        ),
                        // Tactical rounded square (matching Calendar)
                        borderRadius: BorderRadius.circular(2.0),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Divider(color: const Color(0xFF0A0A0A), thickness: 1, height: 1), // Stealth divider
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // Monthly Goal - Minimalist (No Container)
  Widget _buildGoalProgress() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getGoalProgress(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'progress': 0.0, 'completed': 0, 'total': 20};
        final progress = data['progress'] as double;
        final completed = data['completed'] as int;
        final total = data['total'] as int;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - Monospace (영어 고정 - Design Element)
            Row(
              children: [
                const Text(
                  'MONTHLY GOAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF616161), // Colors.grey[700]
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 14, color: Color(0xFF616161)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/goal_settings');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress number - big
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                fontFamily: 'Courier',
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 8),
            // Details
            Text(
              '$completed / $total DAYS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Progress Bar - Visual Anchor
            Center(
              child: SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2.0,
                  backgroundColor: const Color(0xFF0A0A0A), // Very dark, barely visible
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // White - High-End Monochrome
                  borderRadius: BorderRadius.zero, // Sharp edges
                ),
              ),
            ),
            const SizedBox(height: 32),
            Divider(color: const Color(0xFF0A0A0A), thickness: 1, height: 1), // Stealth divider
          ],
        );
      },
    );
  }

  // Helper methods
  Future<Session?> _getTodaySession() async {
    final today = sessionRepo.ymd(DateTime.now());
    return await sessionRepo.get(today);
  }

  Future<Set<String>> _getWorkoutDates() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    return sessions.map((s) => s.ymd).toSet();
  }

  Future<Map<String, dynamic>> _getGoalProgress() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final sessions = await sessionRepo.getSessionsInRange(startOfMonth, endOfMonth);
    final workoutDays = sessions.where((s) => s.isWorkoutDay).length;
    final monthlyGoal = 20; // 기본 목표
    
    return {
      'progress': (workoutDays / monthlyGoal).clamp(0.0, 1.0),
      'completed': workoutDays,
      'total': monthlyGoal,
    };
  }
}

// 🎯 Big Three Widget - Tactical HUD Style (FORCED)
class _HomeBigThreeWidget extends StatelessWidget {
  final SessionRepo sessionRepo;
  
  const _HomeBigThreeWidget({required this.sessionRepo});

  Future<double> _calculateBigThreeTotal() async {
    // Get all workout sessions
    final sessions = await sessionRepo.getWorkoutSessions();
    
    // Track max weights for each of the Big 3
    double maxBench = 0;
    double maxSquat = 0;
    double maxDeadlift = 0;
    
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final name = exercise.name.toLowerCase();
        
        // Find max weight for this exercise
        double maxWeight = 0;
        for (final set in exercise.sets) {
          if (set.weight > maxWeight) {
            maxWeight = set.weight;
          }
        }
        
        // Categorize into Big 3
        if (name.contains('bench') || name.contains('벤치') || name.contains('ベンチ')) {
          if (maxWeight > maxBench) maxBench = maxWeight;
        } else if (name.contains('squat') || name.contains('스쿼트') || name.contains('スクワット')) {
          if (maxWeight > maxSquat) maxSquat = maxWeight;
        } else if (name.contains('deadlift') || name.contains('데드리프트') || name.contains('デッドリフト')) {
          if (maxWeight > maxDeadlift) maxDeadlift = maxWeight;
        }
      }
    }
    
    return maxBench + maxSquat + maxDeadlift;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateBigThreeTotal(),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;
        final hasData = total > 0;
        
        // Display value
        final displayValue = hasData ? '${total.toInt()} KG' : '-- KG';
        
        return GestureDetector(
          onTap: () {
            print('🎯 Big Three tapped - Navigating to Analysis');
            Navigator.pushNamed(context, '/analysis');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent, // FORCE TRANSPARENT
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2), // Thin subtle border
                width: 1.0,
              ),
              borderRadius: BorderRadius.zero, // FORCE SHARP CORNERS
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side: Label & Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BIG 3 TOTAL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: hasData 
                              ? const Color(0xFF69F0AE) // Neon Green
                              : Colors.grey[700],
                          fontSize: 24,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Side: Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🎯 Volume Widget - Tactical HUD Style (FORCED)
class _HomeVolumeWidget extends StatelessWidget {
  final SessionRepo sessionRepo;
  
  const _HomeVolumeWidget({required this.sessionRepo});

  Future<double> _calculateWeeklyVolume() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final sessions = await sessionRepo.getSessionsInRange(startOfWeek, endOfWeek);
    
    double totalVolume = 0;
    for (final session in sessions) {
      totalVolume += session.totalVolume;
    }
    
    return totalVolume;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateWeeklyVolume(),
      builder: (context, snapshot) {
        final volume = snapshot.data ?? 0;
        final hasData = volume > 0;
        
        // Display value with unit
        String displayValue;
        if (!hasData) {
          displayValue = '-- KG';
        } else if (volume >= 1000) {
          displayValue = '${(volume / 1000).toStringAsFixed(1)} TON';
        } else {
          displayValue = '${volume.toInt()} KG';
        }
        
        return GestureDetector(
          onTap: () {
            print('🎯 Volume tapped - Navigating to Analysis');
            Navigator.pushNamed(context, '/analysis');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent, // FORCE TRANSPARENT
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2), // Thin subtle border
                width: 1.0,
              ),
              borderRadius: BorderRadius.zero, // FORCE SHARP CORNERS
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side: Label & Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEEKLY VOL',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: hasData 
                              ? const Color(0xFF448AFF) // Electric Blue
                              : Colors.grey[700],
                          fontSize: 24,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Side: Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🏆 업적 미리보기 카드
class _AchievementPreviewCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  const _AchievementPreviewCard({required this.sessionRepo});

  @override
  State<_AchievementPreviewCard> createState() => _AchievementPreviewCardState();
}

class _AchievementPreviewCardState extends State<_AchievementPreviewCard> {
  AchievementService? _service;
  List<Achievement> _recentUnlocked = [];
  int _totalUnlocked = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _service = AchievementService(sessionRepo: widget.sessionRepo);
    await _service!.init();
    await _service!.checkNewUnlocks();
    
    if (mounted) {
      setState(() {
        _recentUnlocked = _service!.getUnlockedAchievements().take(3).toList();
        _totalUnlocked = _service!.unlockedIds.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_service != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AchievementsPage(achievementService: _service!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: IronTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '🏆 ${context.l10n.achievement}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: IronTheme.textHigh,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_totalUnlocked/${Achievements.all.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: IronTheme.textMedium,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: IronTheme.textMedium, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const SizedBox(height: 50)
            else if (_recentUnlocked.isEmpty)
              Text(
                context.l10n.achieveFirst,
                style: TextStyle(color: IronTheme.textMedium, fontSize: 14),
              )
            else
              Row(
                children: _recentUnlocked.map((a) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: a.color.withValues(alpha: 0.5)),
                    ),
                    child: Icon(a.icon, color: a.color, size: 24),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTrendCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  const _ActivityTrendCard({required this.sessionRepo, required this.exerciseRepo});

  @override
  State<_ActivityTrendCard> createState() => _ActivityTrendCardState();
}

class _ActivityTrendCardState extends State<_ActivityTrendCard> {
  List<double>? _weeklyVolumes;
  double? _avgThisWeek;
  double? _diff;
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActivityTrend());
  }
  
  Future<void> _updateActivityTrend() async {
    try {
      final now = DateTime.now();
      final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
      final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
      final endOfLastWeek = endOfThisWeek.subtract(const Duration(days: 7));

      final thisWeekSessions = await widget.sessionRepo.getSessionsInRange(startOfThisWeek, endOfThisWeek);
      final lastWeekSessions = await widget.sessionRepo.getSessionsInRange(startOfLastWeek, endOfLastWeek);

      final thisWeekVolumes = _calculateDailyVolumes(thisWeekSessions, startOfThisWeek);
      final lastWeekTotalVolume = _calculateTotalVolume(lastWeekSessions);
      final thisWeekTotalVolume = _calculateTotalVolume(thisWeekSessions);

      final avgThisWeek = thisWeekTotalVolume / (now.weekday);
      final avgLastWeek = lastWeekTotalVolume / 7;
      final diff = avgThisWeek - avgLastWeek;

      if (mounted) {
        setState(() {
          _weeklyVolumes = thisWeekVolumes;
          _avgThisWeek = avgThisWeek;
          _diff = diff;
          _isLoading = false;
          _hasData = thisWeekSessions.isNotEmpty || lastWeekSessions.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
      }
    }
  }

  double _calculateTotalVolume(List<dynamic> sessions) => sessions.fold(0.0, (sum, s) => sum + s.totalVolume);

  List<double> _calculateDailyVolumes(List<dynamic> sessions, DateTime startOfWeek) {
    List<double> dailyVolumes = List.filled(7, 0.0);
    for (var session in sessions) {
      final dayIndex = widget.sessionRepo.ymdToDateTime(session.ymd).difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyVolumes[dayIndex] = session.totalVolume;
      }
    }
    return dailyVolumes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoading
          ? _buildLoadingSkeleton()
          : !_hasData
              ? _buildEmptyState(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.activityTrend,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: IronTheme.textHigh,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: IronTheme.textMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildFilterTab(context.l10n.time, isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterTab(context.l10n.volume, isSelected: false),
                        const SizedBox(width: 8),
                        _buildFilterTab(context.l10n.density, isSelected: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.weeklyAverageVolume(_avgThisWeek!.toStringAsFixed(0)),
                          style: TextStyle(
                            fontSize: 15,
                            color: IronTheme.textHigh,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.weeklyComparison('${_diff! >= 0 ? '+' : ''}${_diff!.toStringAsFixed(0)}'),
                          style: TextStyle(
                            fontSize: 13,
                            color: IronTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: _weeklyVolumes!.every((v) => v == 0)
                          ? _buildEmptyChart(context)
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (_weeklyVolumes!.isEmpty ? 1000 : _weeklyVolumes!.reduce((a, b) => a > b ? a : b)) * 1.2,
                                barTouchData: BarTouchData(enabled: false),
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final days = [
                                          context.l10n.weekdayMon,
                                          context.l10n.weekdayTue,
                                          context.l10n.weekdayWed,
                                          context.l10n.weekdayThu,
                                          context.l10n.weekdayFri,
                                          context.l10n.weekdaySat,
                                          context.l10n.weekdaySun,
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            days[value.toInt() % 7],
                                            style: TextStyle(
                                              color: IronTheme.textMedium,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(7, (i) {
                                  return BarChartGroupData(x: i, barRods: [
                                    BarChartRodData(
                                      toY: _weeklyVolumes![i] == 0 ? 0.1 : _weeklyVolumes![i],
                                      color: IronTheme.primary,
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    ),
                                  ]);
                                }),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 120, height: 24, color: Theme.of(context).cardColor),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 18, color: Theme.of(context).cardColor),
          const SizedBox(height: 8),
          Container(width: 150, height: 14, color: Theme.of(context).cardColor),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 150, color: Theme.of(context).cardColor),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? IronTheme.primary : IronTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? IronTheme.textHigh : IronTheme.textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: 40 + (i * 10.0 % 60),
              decoration: BoxDecoration(
                color: IronTheme.surface.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              [
                context.l10n.weekdayMon,
                context.l10n.weekdayTue,
                context.l10n.weekdayWed,
                context.l10n.weekdayThu,
                context.l10n.weekdayFri,
                context.l10n.weekdaySat,
                context.l10n.weekdaySun,
              ][i],
              style: TextStyle(
                color: IronTheme.textMedium,
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.activityTrend,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: IronTheme.textHigh,
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.bar_chart,
                size: 48,
                color: IronTheme.textMedium,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noWorkoutRecords,
                style: TextStyle(
                  fontSize: 16,
                  color: IronTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
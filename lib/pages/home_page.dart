import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../data/settings_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/auth_repo.dart';
import '../core/l10n_extensions.dart';
import '../core/iron_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'shell_page.dart';
import '../models/session.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../services/gamification_service.dart';
import 'achievements_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  
  // GetIt으로 가져온 repositories를 저장할 변수들
  late SessionRepo sessionRepo;
  late UserRepo userRepo;
  late ExerciseLibraryRepo exerciseRepo;
  late SettingsRepo settingsRepo;
  late AuthRepo authRepo;

  @override
  void initState() {
    super.initState();
    
    // GetIt에서 repositories 가져오기
    sessionRepo = getIt<SessionRepo>();
    userRepo = getIt<UserRepo>();
    exerciseRepo = getIt<ExerciseLibraryRepo>();
    settingsRepo = getIt<SettingsRepo>();
    authRepo = getIt<AuthRepo>();
    
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
      appBar: AppBar(
        backgroundColor: IronTheme.background,
        title: Text(
          'Iron Log - Home',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: IronTheme.textHigh,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: IronTheme.textHigh),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: IronTheme.textHigh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 히어로 섹션 (레벨 + 스트릭 통합 카드)
              SlideTransition(
                position: _slideAnimations[0],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildHeroStatusCard(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 메인 액션 (오늘의 운동 시작) - 단일 버튼!
              SlideTransition(
                position: _slideAnimations[1],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildMainActionCard(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 주간 요약 (이번 주 운동 현황)
              SlideTransition(
                position: _slideAnimations[2],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildWeeklyCalendar(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 목표 진행률 (원형 차트)
              SlideTransition(
                position: _slideAnimations[3],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _buildGoalProgress(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 업적 미리보기
              SlideTransition(
                position: _slideAnimations[4],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _AchievementPreviewCard(sessionRepo: sessionRepo),
                ),
              ),
              const SizedBox(height: 16),
              
              // 활동 트렌드
              SlideTransition(
                position: _slideAnimations[5],
                child: FadeTransition(
                  opacity: _animationController,
                  child: _ActivityTrendCard(sessionRepo: sessionRepo, exerciseRepo: exerciseRepo),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 히어로 섹션 (레벨 + 스트릭 통합 카드)
  Widget _buildHeroStatusCard() {
    return FutureBuilder<GamificationService?>(
      future: _initGamificationService(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 140,
            decoration: BoxDecoration(
              color: IronTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }

        final service = snapshot.data!;
        final data = service.data;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IronTheme.surface.withValues(alpha: 0.8),
                IronTheme.surface.withValues(alpha: 1.0),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: IronTheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 좌측: 레벨 원형 그래프
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${data.level}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: IronTheme.textHigh,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 레벨 프로그래스 바
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: data.levelProgress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [IronTheme.primary, IronTheme.primary.withValues(alpha: 0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${data.totalXP}/${data.totalXP + data.xpToNextLevel} XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: IronTheme.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // 우측: 스트릭 현황
              Expanded(
                flex: 4,
                child: FutureBuilder<int>(
                  future: _getStreak(),
                  builder: (context, streakSnapshot) {
                    final streak = streakSnapshot.data ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: IronTheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.streakDays(streak),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<int>(
                          future: _getWeeklyWorkouts(),
                          builder: (context, weeklySnapshot) {
                            final weeklyCount = weeklySnapshot.data ?? 0;
                            return Text(
                              '이번 주 $weeklyCount/7일 완료',
                              style: TextStyle(
                                fontSize: 12,
                                color: IronTheme.textMedium,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 메인 액션 (오늘의 운동 시작) - 단일 버튼!
  Widget _buildMainActionCard() {
    return FutureBuilder<Session?>(
      future: _getTodaySession(),
      builder: (context, snapshot) {
        final todaySession = snapshot.data;
        final hasPlan = todaySession != null && 
                       todaySession.isWorkoutDay && 
                       todaySession.exercises.isNotEmpty;
        final isRest = todaySession?.isRest ?? false;
        final isCompleted = todaySession?.isCompleted ?? false;

        if (isRest) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: IronTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.rest,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘은 휴식하는 날입니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: IronTheme.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!hasPlan) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: IronTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: IronTheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.todayWorkoutPlan,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '운동을 추가해서 오늘의 계획을 세워보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: IronTheme.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 캘린더 탭으로 이동
                      final shellState = context.findAncestorStateOfType<ShellPageState>();
                      shellState?.navigateToCalendar();
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(context.l10n.planWorkout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IronTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 계획이 있는 경우
        final exerciseCount = todaySession.exercises.length;
        final completedCount = todaySession.exercises.where((e) => 
          e.sets.isNotEmpty && e.sets.every((s) => s.isCompleted)).length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted 
                ? [const Color(0xFF00C853), const Color(0xFF4CAF50)]
                : [IronTheme.primary, IronTheme.primary.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.play_circle_filled,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted ? '운동 완료!' : '오늘의 운동',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$completedCount/$exerciseCount 운동 완료',
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 캘린더 탭으로 이동
                    final shellState = context.findAncestorStateOfType<ShellPageState>();
                    shellState?.navigateToCalendar();
                  },
                  icon: Icon(
                    isCompleted ? Icons.edit : Icons.play_arrow,
                    size: 20,
                  ),
                  label: Text(
                    isCompleted ? context.l10n.editWorkout : context.l10n.startWorkout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isCompleted ? const Color(0xFF00C853) : IronTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 주간 요약 (이번 주 운동 현황)
  Widget _buildWeeklyCalendar() {
    return FutureBuilder<Set<String>>(
      future: _getWorkoutDates(),
      builder: (context, snapshot) {
        final workoutDates = snapshot.data ?? <String>{};
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IronTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.thisWeekWorkout,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final date = startOfWeek.add(Duration(days: index));
                  final dateYmd = sessionRepo.ymd(date);
                  final hasWorkout = workoutDates.contains(dateYmd);
                  final isToday = sessionRepo.ymd(date) == sessionRepo.ymd(now);
                  final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
                  
                  return Column(
                    children: [
                      Text(
                        dayNames[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: IronTheme.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasWorkout 
                            ? IronTheme.primary
                            : isToday 
                              ? Colors.grey[700]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isToday && !hasWorkout
                            ? Border.all(color: Colors.grey[600]!)
                            : null,
                        ),
                        child: Center(
                          child: hasWorkout
                            ? const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isToday ? Colors.white : Colors.grey[500],
                                ),
                              ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: _getWeeklyStats(),
                builder: (context, statsSnapshot) {
                  final stats = statsSnapshot.data ?? {'volume': '0kg', 'time': '0분'};
                  return Row(
                    children: [
                      Expanded(
                        child: _buildWeeklyStat(context.l10n.totalVolumeLabel, stats['volume'], Icons.bar_chart),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildWeeklyStat(context.l10n.workoutTimeLabel, stats['time'], Icons.timer),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IronTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: IronTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: IronTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 목표 진행률 (원형 차트)
  Widget _buildGoalProgress() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getGoalProgress(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {'progress': 0.0, 'completed': 0, 'total': 20};
        final progress = data['progress'] as double;
        final completed = data['completed'] as int;
        final total = data['total'] as int;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IronTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // 원형 차트
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    // 배경 원
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 8,
                        ),
                      ),
                    ),
                    // 진행률 원
                    Transform.rotate(
                      angle: -1.5708, // -90도 (12시 방향부터 시작)
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            IronTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    // 중앙 텍스트
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // 목표 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.thisMonthGoal,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$total일 중 $completed일 완료',
                      style: TextStyle(
                        fontSize: 14,
                        color: IronTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${total - completed}일 남음',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Future<GamificationService?> _initGamificationService() async {
    final service = GamificationService(sessionRepo: sessionRepo);
    await service.init();
    return service;
  }

  Future<Session?> _getTodaySession() async {
    final today = sessionRepo.ymd(DateTime.now());
    return await sessionRepo.get(today);
  }

  Future<int> _getStreak() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    if (sessions.isEmpty) return 0;

    sessions.sort((a, b) => b.ymd.compareTo(a.ymd)); // 최신순 정렬
    
    final today = DateTime.now();
    final todayYmd = sessionRepo.ymd(today);
    final yesterdayYmd = sessionRepo.ymd(today.subtract(const Duration(days: 1)));
    
    // 오늘이나 어제 운동했는지 확인
    final hasToday = sessions.any((s) => s.ymd == todayYmd);
    final hasYesterday = sessions.any((s) => s.ymd == yesterdayYmd);
    
    if (!hasToday && !hasYesterday) {
      return 0; // 연속 기록이 끊어짐
    }
    
    int streak = 0;
    DateTime checkDate = hasToday ? today : today.subtract(const Duration(days: 1));
    
    // 연속일 계산
    while (true) {
      final ymd = sessionRepo.ymd(checkDate);
      if (sessions.any((s) => s.ymd == ymd)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<int> _getWeeklyWorkouts() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final sessions = await sessionRepo.getSessionsInRange(startOfWeek, endOfWeek);
    return sessions.where((s) => s.isWorkoutDay).length;
  }

  Future<Set<String>> _getWorkoutDates() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    return sessions.map((s) => s.ymd).toSet();
  }

  Future<Map<String, dynamic>> _getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final sessions = await sessionRepo.getSessionsInRange(startOfWeek, endOfWeek);
    final totalVolume = sessions.fold(0.0, (sum, s) => sum + s.totalVolume);
    
    return {
      'volume': '${(totalVolume / 1000).toStringAsFixed(1)}t',
      'time': '${sessions.length * 60}분', // 임시로 세션당 60분으로 계산
    };
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
                '운동 기록이 없습니다',
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
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../data/settings_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/auth_repo.dart';
import '../models/user_profile.dart';
import '../core/l10n_extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'user_info_form_page.dart';
import 'plan_page.dart';
import '../models/session.dart';
import './settings_page.dart';
import './achievements_page.dart';
import './power_shop_page.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../services/gamification_service.dart';

class HomePage extends StatelessWidget {
  final SessionRepo sessionRepo;
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;
  final AuthRepo authRepo;

  const HomePage(
      {super.key,
      required this.sessionRepo,
      required this.userRepo,
      required this.exerciseRepo,
      required this.settingsRepo, required this.authRepo});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더를 SliverAppBar로 변경
            SliverToBoxAdapter(
              child: _HeaderComponent(
                userRepo: userRepo,
                exerciseRepo: exerciseRepo,
                settingsRepo: settingsRepo,
                sessionRepo: sessionRepo,
                authRepo: authRepo,
              ),
            ),
            // 본문 콘텐츠
            SliverToBoxAdapter(
            child: _BodyComponent(
              sessionRepo: sessionRepo,
              userRepo: userRepo,
              exerciseRepo: exerciseRepo,
              settingsRepo: settingsRepo,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// 3.1 HeaderComponent (상단 헤더) - StatefulWidget으로 변경
class _HeaderComponent extends StatefulWidget {
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;
  final SessionRepo sessionRepo;
  final AuthRepo authRepo;

  const _HeaderComponent(
      {required this.userRepo,
      required this.exerciseRepo,
      required this.settingsRepo,
      required this.sessionRepo,
      required this.authRepo});

  @override
  State<_HeaderComponent> createState() => _HeaderComponentState();
}

class _HeaderComponentState extends State<_HeaderComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: Row(
        children: [
          // Lifto 로고 (흰색, 22px)
          const Text(
            'Lifto',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // 알림 아이콘
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('알림 기능은 준비 중입니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 4),
          // 설정 아이콘
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userRepo: widget.userRepo,
                    exerciseRepo: widget.exerciseRepo,
                    settingsRepo: widget.settingsRepo,
                    sessionRepo: widget.sessionRepo,
                    authRepo: widget.authRepo,
                  ),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

// 3.2 BodyComponent (본문) - 애니메이션을 위해 StatefulWidget으로 변경
class _BodyComponent extends StatefulWidget {
  final SessionRepo sessionRepo;
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;

  const _BodyComponent({
    required this.sessionRepo,
    required this.userRepo,
    required this.exerciseRepo,
    required this.settingsRepo,
  });

  @override
  State<_BodyComponent> createState() => _BodyComponentState();
}

class _BodyComponentState extends State<_BodyComponent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
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
    final cards = [
      _XPLevelCard(sessionRepo: widget.sessionRepo),
      _StreakCard(sessionRepo: widget.sessionRepo),
      _TodaySummaryCard(
        sessionRepo: widget.sessionRepo,
        exerciseRepo: widget.exerciseRepo,
        settingsRepo: widget.settingsRepo,
      ),
      _AchievementPreviewCard(sessionRepo: widget.sessionRepo),
      _MyGoalCard(sessionRepo: widget.sessionRepo, userRepo: widget.userRepo, exerciseRepo: widget.exerciseRepo, settingsRepo: widget.settingsRepo),
      _ActivityTrendCard(sessionRepo: widget.sessionRepo, exerciseRepo: widget.exerciseRepo, settingsRepo: widget.settingsRepo),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: List.generate(cards.length, (index) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _animationController,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: cards[index],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ⭐ XP/레벨 카드 (듀오링고 스타일)
class _XPLevelCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  const _XPLevelCard({required this.sessionRepo});

  @override
  State<_XPLevelCard> createState() => _XPLevelCardState();
}

class _XPLevelCardState extends State<_XPLevelCard> {
  GamificationService? _service;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    _service = GamificationService(sessionRepo: widget.sessionRepo);
    await _service!.init();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _service == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    final data = _service!.data;
    final league = data.league;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [league.color.withValues(alpha: 0.3), const Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: league.color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        children: [
          // 상단: 리그 + 레벨 + 젬
          Row(
            children: [
              // 리그 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: league.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: league.color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(league.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      league.getName(context),
                      style: TextStyle(
                        color: league.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 파워 (클릭하면 상점으로)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PowerShopPage(gamificationService: _service!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💪', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${data.power}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 레벨 + XP 바
          Row(
            children: [
              // 레벨 원형
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [league.color, league.color.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    '${data.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // XP 진행바
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.level(data.level),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.l10n.xpRemaining(data.xpToNextLevel),
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: data.levelProgress,
                        backgroundColor: const Color(0xFF2C2C2E),
                        color: league.color,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.totalXpWeekly(data.totalXP, data.weeklyXP),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔥 연속 운동 스트릭 카드
class _StreakCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  const _StreakCard({required this.sessionRepo});

  @override
  State<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<_StreakCard> {
  int _streak = 0;
  int _longestStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStreak());
  }

  Future<void> _loadStreak() async {
    final sessions = await widget.sessionRepo.getWorkoutSessions();
    if (sessions.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // 날짜별로 정렬 (최신순)
    sessions.sort((a, b) => b.ymd.compareTo(a.ymd));
    
    final today = DateTime.now();
    final todayYmd = widget.sessionRepo.ymd(today);
    final yesterdayYmd = widget.sessionRepo.ymd(today.subtract(const Duration(days: 1)));
    
    // 현재 스트릭 계산
    int streak = 0;
    DateTime checkDate = today;
    
    // 오늘 또는 어제부터 시작
    final hasToday = sessions.any((s) => s.ymd == todayYmd);
    final hasYesterday = sessions.any((s) => s.ymd == yesterdayYmd);
    
    if (!hasToday && !hasYesterday) {
      streak = 0;
    } else {
      if (!hasToday) {
        checkDate = today.subtract(const Duration(days: 1));
      }
      
      while (true) {
        final ymd = widget.sessionRepo.ymd(checkDate);
        if (sessions.any((s) => s.ymd == ymd)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    // 최장 스트릭 계산
    int longest = 0;
    int current = 0;
    DateTime? prevDate;
    
    for (final session in sessions.reversed) {
      final date = widget.sessionRepo.ymdToDateTime(session.ymd);
      if (prevDate == null) {
        current = 1;
      } else {
        final diff = prevDate.difference(date).inDays;
        if (diff == 1) {
          current++;
        } else {
          longest = current > longest ? current : longest;
          current = 1;
        }
      }
      prevDate = date;
    }
    longest = current > longest ? current : longest;

    if (mounted) {
      setState(() {
        _streak = streak;
        _longestStreak = longest;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(height: 80),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _streak > 0 
            ? [const Color(0xFFFF6B35), const Color(0xFFFF8C42)]
            : [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 불꽃 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              _streak > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                          _streak > 0 ? context.l10n.streakMessage(_streak) : context.l10n.startWorkoutToday,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _longestStreak > 0 ? context.l10n.longestRecord(_longestStreak) : context.l10n.createFirstStreak,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 오늘의 운동 요약 카드
class _TodaySummaryCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;
  const _TodaySummaryCard({
    required this.sessionRepo,
    required this.exerciseRepo,
    required this.settingsRepo,
  });

  @override
  State<_TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<_TodaySummaryCard> {
  Session? _todaySession;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadToday());
  }

  Future<void> _loadToday() async {
    final today = widget.sessionRepo.ymd(DateTime.now());
    final session = await widget.sessionRepo.get(today);
    if (mounted) {
      setState(() {
        _todaySession = session;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(height: 100),
      );
    }

    final hasWorkout = _todaySession?.isWorkoutDay ?? false;
    final isRest = _todaySession?.isRest ?? false;
    final exerciseCount = _todaySession?.exercises.length ?? 0;
    final totalSets = _todaySession?.exercises.fold<int>(0, (sum, e) => sum + e.sets.length) ?? 0;
    final totalVolume = _todaySession?.totalVolume ?? 0;

    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlanPage(
              date: DateTime.now(),
              repo: widget.sessionRepo,
              exerciseRepo: widget.exerciseRepo,
              settingsRepo: widget.settingsRepo,
              isFromTodayWorkout: true,
              isViewOnly: hasWorkout, // 완료된 운동이면 조회 모드
            ),
          ),
        );
        if (mounted) _loadToday();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.todayWorkout,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? const Color(0xFF34C759)
                      : (isRest ? const Color(0xFF007AFF) : const Color(0xFF2C2C2E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasWorkout
                      ? context.l10n.completed
                      : (isRest ? context.l10n.rest : context.l10n.notCompleted),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (hasWorkout || isRest) ? Colors.white : const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasWorkout) ...[
            Row(
              children: [
                _buildStatItem(Icons.fitness_center, context.l10n.exerciseUnit(exerciseCount), context.l10n.exercise),
                const SizedBox(width: 24),
                _buildStatItem(Icons.repeat, context.l10n.setsUnit(totalSets), context.l10n.totalSets),
                const SizedBox(width: 24),
                _buildStatItem(Icons.speed, '${(totalVolume / 1000).toStringAsFixed(1)}t', context.l10n.volume),
              ],
            ),
          ] else if (isRest) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Center(
                child: Text(
                  context.l10n.rest, // 휴식
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ] else ...[
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlanPage(
                      date: DateTime.now(),
                      repo: widget.sessionRepo,
                      exerciseRepo: widget.exerciseRepo,
                      settingsRepo: widget.settingsRepo,
                      isFromTodayWorkout: true,
                    ),
                  ),
                );
                if (mounted) _loadToday();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Color(0xFF007AFF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.startWorkoutNow,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF007AFF), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }
}

// 업데이트 배너 카드 제거 - 알림 아이콘으로 대체

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
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '🏆 ${context.l10n.achievement}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '$_totalUnlocked/${Achievements.all.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const SizedBox(height: 50)
            else if (_recentUnlocked.isEmpty)
              Text(
                context.l10n.achieveFirst,
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
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

class _MyGoalCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  final UserRepo userRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;

  const _MyGoalCard({
    required this.sessionRepo,
    required this.userRepo,
    required this.exerciseRepo,
    required this.settingsRepo,
  });

  @override
  State<_MyGoalCard> createState() => _MyGoalCardState();
}

class _MyGoalCardState extends State<_MyGoalCard> {
  // 두 가지 목표에 대한 상태
  double? _daysProgress;
  int? _workoutDays;
  int? _monthlyGoal;
  double? _volumeProgress;
  double? _totalVolume;
  double? _monthlyVolumeGoal;

  bool get _isLoading => _daysProgress == null || _volumeProgress == null;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 데이터를 로드하여 자연스러운 애니메이션 보장
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoals());
  }

  Future<void> _loadGoals() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Future.wait를 사용하여 두 비동기 작업을 병렬로 실행
    final results = await Future.wait([
      widget.sessionRepo.getSessionsInRange(startOfMonth, endOfMonth),
      widget.userRepo.getUserProfile(),
    ]);

    final sessions = results[0] as List<dynamic>;
    final profile = results[1] as UserProfile?;

    // 1. 운동 일수 목표 계산
    final workoutDays = sessions.where((s) => s.isWorkoutDay).length;
    final monthlyGoal = profile?.monthlyWorkoutGoal ?? 20;

    if (mounted) {
      setState(() {
        _daysProgress = (workoutDays / monthlyGoal).clamp(0.0, 1.0);
        _workoutDays = workoutDays;
        _monthlyGoal = monthlyGoal;
      });
    }

    // 2. 운동 볼륨 목표 계산
    final totalVolume = sessions.fold(0.0, (sum, s) => sum + (s as Session).totalVolume);
    final monthlyVolumeGoal = profile?.monthlyVolumeGoal ?? 100000.0;

    if (mounted) {
      setState(() {
        _volumeProgress = (totalVolume / monthlyVolumeGoal).clamp(0.0, 1.0);
        _totalVolume = totalVolume;
        _monthlyVolumeGoal = monthlyVolumeGoal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _isLoading
          ? _buildLoadingSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.myGoal,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserInfoFormPage(userRepo: widget.userRepo),
                        ));
                        if (result == true && mounted) {
                          _loadGoals();
                        }
                      },
                      child: Text(
                        context.l10n.edit,
                        style: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildGoalIndicator(
                    text: context.l10n.workoutDaysGoal(_workoutDays!, _monthlyGoal!), progress: _daysProgress!),
                const SizedBox(height: 20),
                _buildGoalIndicator(
                    text: context.l10n.workoutVolumeGoal(_totalVolume!.toStringAsFixed(0), _monthlyVolumeGoal!.toStringAsFixed(0)), progress: _volumeProgress!),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlanPage(
                          date: DateTime.now(),
                          repo: widget.sessionRepo,
                          exerciseRepo: widget.exerciseRepo,
                          settingsRepo: widget.settingsRepo,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    context.l10n.startWorkout,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGoalIndicator({required String text, required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFFAAAAAA),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2C2C2E),
            color: const Color(0xFF007AFF),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 24, color: Theme.of(context).cardColor),
          const SizedBox(height: 24),
          Container(width: 200, height: 18, color: Theme.of(context).cardColor),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 10, color: Theme.of(context).cardColor),
          const SizedBox(height: 16),
          Container(width: 250, height: 18, color: Theme.of(context).cardColor),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 10, color: Theme.of(context).cardColor),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 50, color: Theme.of(context).cardColor, margin: const EdgeInsets.only(top: 8)),
        ],
      ),
    );
  }
}

class _ActivityTrendCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo settingsRepo;

  const _ActivityTrendCard({
    required this.sessionRepo,
    required this.exerciseRepo,
    required this.settingsRepo,
  });

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
    // 위젯이 빌드된 후 데이터를 로드하여 자연스러운 애니메이션 보장
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActivityTrend());
  }
  
  Future<void> _updateActivityTrend() async {
    try {
      final now = DateTime.now();
      // 이번 주 월요일 ~ 일요일
      final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));
      // 저번 주 월요일 ~ 일요일
      final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
      final endOfLastWeek = endOfThisWeek.subtract(const Duration(days: 7));

      final thisWeekSessions = await widget.sessionRepo.getSessionsInRange(startOfThisWeek, endOfThisWeek);
      final lastWeekSessions = await widget.sessionRepo.getSessionsInRange(startOfLastWeek, endOfLastWeek);

      final thisWeekVolumes = _calculateDailyVolumes(thisWeekSessions, startOfThisWeek);
      final lastWeekTotalVolume = _calculateTotalVolume(lastWeekSessions);
      final thisWeekTotalVolume = _calculateTotalVolume(thisWeekSessions);

      final avgThisWeek = thisWeekTotalVolume / (now.weekday); // 이번주 오늘까지의 평균
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
        color: const Color(0xFF1E1E1E),
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
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFFAAAAAA),
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
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.weeklyComparison('${_diff! >= 0 ? '+' : ''}${_diff!.toStringAsFixed(0)}'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF007AFF),
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
                            gridData: const FlGridData(show: false), // 격자선 제거
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
                                        style: const TextStyle(
                                          color: Color(0xFFAAAAAA),
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
                                  color: const Color(0xFF007AFF),
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), // 상단만 둥글게
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
        color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFAAAAAA),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 빈 그래프 스켈레톤 UI
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
                color: const Color(0xFF2C2C2E),
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
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  // 데이터 없을 때 표시
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.activityTrend,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.show_chart,
                size: 64,
                color: Color(0xFF2C2C2E),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noRecentWorkout,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlanPage(
                        date: DateTime.now(),
                        repo: widget.sessionRepo,
                        exerciseRepo: widget.exerciseRepo,
                        settingsRepo: widget.settingsRepo,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  minimumSize: const Size(0, 50),
                ),
                child: Text(
                  context.l10n.startWorkout,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

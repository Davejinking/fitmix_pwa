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
import 'workout_page.dart';
import '../models/session.dart';
import 'shell_page.dart';
import './settings_page.dart';

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
          // FitMix 로고 (흰색, 22px)
          const Text(
            'FitMix',
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
              // TODO: 알림 페이지로 이동
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

  const _BodyComponent({required this.sessionRepo, required this.userRepo});

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

    final cardCount = 2; // 업데이트 배너 제거로 2개로 변경
    _slideAnimations = List.generate(cardCount, (index) {
      final start = 0.2 * index;
      final end = start + 0.6;
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOut),
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
      _MyGoalCard(sessionRepo: widget.sessionRepo, userRepo: widget.userRepo),
      _ActivityTrendCard(sessionRepo: widget.sessionRepo),
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

// 업데이트 배너 카드 제거 - 알림 아이콘으로 대체

class _MyGoalCard extends StatefulWidget {
  final SessionRepo sessionRepo;
  final UserRepo userRepo;

  const _MyGoalCard({required this.sessionRepo, required this.userRepo});

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
                      child: const Text(
                        '수정',
                        style: TextStyle(
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
                    final result = await Navigator.of(context).push<int>(
                      MaterialPageRoute(
                        builder: (context) => WorkoutPage(sessionRepo: widget.sessionRepo),
                      ),
                    );

                    if (result == 1 && context.mounted) {
                      final shellState = context.findAncestorStateOfType<ShellPageState>();
                      shellState?.onItemTapped(1);
                    }
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
  const _ActivityTrendCard({required this.sessionRepo});

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
              const Text(
                '최근 운동 기록이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (context) => WorkoutPage(sessionRepo: widget.sessionRepo),
                    ),
                  );

                  if (result == 1 && context.mounted) {
                    final shellState = context.findAncestorStateOfType<ShellPageState>();
                    shellState?.onItemTapped(1);
                  }
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

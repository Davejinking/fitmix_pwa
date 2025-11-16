import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../data/settings_repo.dart';
import '../data/exercise_library_repo.dart';
import '../models/user_profile.dart';
import '../data/auth_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/burn_fit_style.dart';
import '../core/l10n_extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'user_info_form_page.dart';
import 'workout_page.dart';
import 'profile_page.dart';
import 'upgrade_page.dart';
import '../models/session.dart';
import 'settings_page.dart';
import 'shell_page.dart';

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
    // 2. 화면 컴포넌트 계층 구조
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 3.1 HeaderComponent
            _HeaderComponent(
                userRepo: userRepo,
                exerciseRepo: exerciseRepo,
                settingsRepo: settingsRepo,
                sessionRepo: sessionRepo,
                authRepo: authRepo),
            // 3.2 BodyComponent
            Expanded(
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
  GoogleSignInAccount? _currentUser;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // AuthRepo와 UserRepo를 통해 사용자 정보를 가져옵니다.
    final user = widget.authRepo.currentUser;
    final profile = await widget.userRepo.getUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _userProfile = profile;
      });
    }
  }

  ImageProvider? get _profileImage {
    if (_userProfile?.profileImage != null) {
      return MemoryImage(_userProfile!.profileImage!);
    }
    if (_currentUser?.photoUrl != null) {
      return NetworkImage(_currentUser!.photoUrl!);
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_currentUser != null)
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userRepo: widget.userRepo,
                    authRepo: widget.authRepo,
                  ),
                )).then((_) => _loadUserData()); // 프로필 수정 후 돌아오면 데이터 새로고침
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _profileImage,
                    radius: 20,
                    onBackgroundImageError: (_, __) {}, // 이미지 로드 실패 시 에러 방지
                    child: _profileImage == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      context.l10n.greetingWithName(_currentUser!.displayName ?? context.l10n.defaultUser),
                      style: BurnFitStyle.title2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(context.l10n.burnFit, style: BurnFitStyle.title1),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UpgradePage()),
              );
            },
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: BurnFitStyle.mediumGray, width: 1),
            ),
            child: Text(context.l10n.upgrade, style: BurnFitStyle.body),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_settings.svg',
              width: 24,
              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                      userRepo: widget.userRepo,
                      exerciseRepo: widget.exerciseRepo,
                      settingsRepo: widget.settingsRepo,
                      sessionRepo: widget.sessionRepo,
                      authRepo: widget.authRepo),
                ),
              );
            },
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

    final cardCount = 3;
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
      const _UpdateBannerCard(),
      _MyGoalCard(sessionRepo: widget.sessionRepo, userRepo: widget.userRepo),
      _ActivityTrendCard(sessionRepo: widget.sessionRepo),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(cards.length, (index) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _animationController,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
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

class _UpdateBannerCard extends StatelessWidget {
  const _UpdateBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BurnFitStyle.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/ic_tv.svg', width: 24, colorFilter: const ColorFilter.mode(BurnFitStyle.white, BlendMode.srcIn)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              context.l10n.updateNote,
              style: BurnFitStyle.body.copyWith(color: BurnFitStyle.white),
            ),
          ),
          SvgPicture.asset('assets/icons/ic_close.svg', width: 24, colorFilter: const ColorFilter.mode(BurnFitStyle.white, BlendMode.srcIn)),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isLoading
          ? _buildLoadingSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(context.l10n.myGoal, style: BurnFitStyle.title2),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserInfoFormPage(userRepo: widget.userRepo),
                        ));
                        // 정보가 성공적으로 저장되면 목표 상태를 다시 계산
                        if (result == true && mounted) {
                          _loadGoals();
                        }
                      },
                      child: Text(context.l10n.editGoal, style: const TextStyle(color: BurnFitStyle.primaryBlue, fontSize: 17)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 두 개의 목표를 표시
                _buildGoalIndicator(
                    text: context.l10n.workoutDaysGoal(_workoutDays!, _monthlyGoal!), progress: _daysProgress!),
                const SizedBox(height: 16),
                _buildGoalIndicator(
                    text: context.l10n.workoutVolumeGoal(_totalVolume!.toStringAsFixed(0), _monthlyVolumeGoal!.toStringAsFixed(0)), progress: _volumeProgress!),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<int>(
                      MaterialPageRoute(
                        builder: (context) => WorkoutPage(sessionRepo: widget.sessionRepo),
                      ),
                    );

                    // WorkoutPage에서 운동 종료 후 탭 인덱스(1)를 반환하면 캘린더 탭으로 이동
                    if (result == 1 && context.mounted) {
                      final shellState = context.findAncestorStateOfType<ShellPageState>();
                      shellState?.onItemTapped(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurnFitStyle.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(context.l10n.startWorkout, style: BurnFitStyle.body.copyWith(color: BurnFitStyle.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
    );
  }

  Widget _buildGoalIndicator({required String text, required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style:
                BurnFitStyle.body.copyWith(color: BurnFitStyle.secondaryGrayText)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: BurnFitStyle.mediumGray,
          color: BurnFitStyle.primaryBlue,
          minHeight: 10,
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
          Container(width: 100, height: 24, color: Colors.white),
          const SizedBox(height: 24),
          Container(width: 200, height: 18, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 10, color: Colors.white),
          const SizedBox(height: 16),
          Container(width: 250, height: 18, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 10, color: Colors.white),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 50, color: Colors.white, margin: const EdgeInsets.only(top: 8)),
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
  bool get _isLoading => _weeklyVolumes == null || _avgThisWeek == null || _diff == null;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 데이터를 로드하여 자연스러운 애니메이션 보장
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActivityTrend());
  }
  
  Future<void> _updateActivityTrend() async {
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
      });
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isLoading
          ? _buildLoadingSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(context.l10n.activityTrend, style: BurnFitStyle.title2),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/icons/ic_arrow_right.svg',
                      width: 16,
                      colorFilter: const ColorFilter.mode(BurnFitStyle.secondaryGrayText, BlendMode.srcIn),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildFilterTab(context.l10n.time, isSelected: true),
                    const SizedBox(width: 8),
                    _buildFilterTab(context.l10n.volume, isSelected: false),
                    const SizedBox(width: 8),
                    _buildFilterTab(context.l10n.density, isSelected: false),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.weeklyAverageVolume(_avgThisWeek!.toStringAsFixed(0)), style: BurnFitStyle.body),
                    const SizedBox(height: 4),
                    Text(context.l10n.weeklyComparison('${_diff! >= 0 ? '+' : ''}${_diff!.toStringAsFixed(0)}'), style: BurnFitStyle.caption.copyWith(color: BurnFitStyle.primaryBlue)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 150,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (_weeklyVolumes!.isEmpty ? 1000 : _weeklyVolumes!.reduce((a, b) => a > b ? a : b)) * 1.2,
                      barTouchData: BarTouchData(enabled: false),
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
                                child: Text(days[value.toInt() % 7]),
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
                            toY: _weeklyVolumes![i],
                            color: BurnFitStyle.primaryBlue,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
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
          Container(width: 120, height: 24, color: Colors.white),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 18, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 150, height: 14, color: Colors.white),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 150, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? BurnFitStyle.primaryBlue : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: BurnFitStyle.caption.copyWith(
          color: isSelected ? BurnFitStyle.white : Theme.of(context).textTheme.bodyLarge!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

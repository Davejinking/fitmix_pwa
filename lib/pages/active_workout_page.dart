import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../widgets/workout/exercise_card.dart';
import '../core/error_handler.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_extensions.dart';
import 'exercise_selection_page_v2.dart';

/// 운동 중 전체 화면 모달 (탭바 숨김, 집중 모드)
class ActiveWorkoutPage extends StatefulWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final DateTime date;

  const ActiveWorkoutPage({
    super.key,
    required this.session,
    required this.repo,
    required this.exerciseRepo,
    required this.date,
  });

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late Session _session;
  
  // 타이머
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  bool _restTimerRunning = false;
  int _defaultRestDuration = 90;
  
  // 휴식 타이머 화면 표시 옵션 (false = 미니 타이머가 디폴트)
  bool _showRestTimerOverlay = false;
  
  // 타이머 UI 표시 여부 (X 버튼으로 숨길 수 있음)
  bool _isTimerUIVisible = false;
  
  // 운동 카드 전체 열기/닫기 상태
  bool _allCardsExpanded = true;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _onSetChecked(bool value) {
    if (value) {
      _startRestTimer(_defaultRestDuration);
      setState(() => _isTimerUIVisible = true); // 타이머 시작 시 UI 표시
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    
    setState(() {
      _restTimerRunning = true;
      _restSeconds = seconds;
    });
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        if (mounted) {
          setState(() => _restSeconds--);
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _restTimerRunning = false);
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }


  /// 운동 종료 확인 바텀 시트 표시
  Future<bool> _showEndWorkoutDialog({bool isCompleting = true}) async {
    final hasIncompleteSets = _session.exercises.any((e) => 
        e.sets.any((s) => !s.isCompleted));
    
    final l10n = AppLocalizations.of(context);
    final completedSets = _session.exercises.fold<int>(
      0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    final totalSets = _session.exercises.fold<int>(
      0, (sum, e) => sum + e.sets.length);
    
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들 바
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF2196F3),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // 제목
              Text(
                isCompleting ? l10n.finishWorkoutTitle : l10n.endWorkout,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // 진행 상황 요약
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF252932),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.timer_outlined,
                      value: _formatTime(_elapsedSeconds),
                      label: l10n.workoutDuration,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[700]),
                    _buildSummaryItem(
                      icon: Icons.check_circle_outline,
                      value: '$completedSets / $totalSets',
                      label: l10n.setsCompleted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 경고 메시지 (미완료 세트가 있을 때)
              if (hasIncompleteSets)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.incompleteSetWarning,
                          style: const TextStyle(fontSize: 13, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  l10n.workoutWillBeSaved,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              // 운동 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isCompleting ? l10n.finishWorkout : l10n.confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 계속하기 버튼
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  l10n.continueWorkout,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    return confirmed == true;
  }
  
  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 20),
        const SizedBox(height: 6),
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
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Future<void> _finishWorkout() async {
    final confirmed = await _showEndWorkoutDialog(isCompleting: true);
    if (!confirmed) return;
    
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    _session.isCompleted = true;
    _session.durationInSeconds = _elapsedSeconds;
    
    await widget.repo.put(_session);
    
    HapticFeedback.heavyImpact();
    
    if (mounted) {
      ErrorHandler.showSuccessSnackBar(context, context.l10n.workoutCompleted);
      Navigator.of(context).pop(true); // true = 운동 완료
    }
  }
  
  /// 뒤로가기 시 중도 종료 처리
  Future<void> _handleBackPress() async {
    final confirmed = await _showEndWorkoutDialog(isCompleting: false);
    if (!confirmed) return;
    
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    // 현재 상태 저장 (미완료)
    await widget.repo.put(_session);
    
    if (mounted) {
      Navigator.of(context).pop(false); // false = 중도 종료
    }
  }
  
  /// 운동 중 운동 추가
  Future<void> _addExercise() async {
    final result = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseSelectionPageV2(),
      ),
    );
    
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        for (final exercise in result) {
          _session.exercises.add(
            Exercise(
              name: exercise.name,
              bodyPart: exercise.bodyPart,
              sets: [ExerciseSet(weight: 0, reps: 0)],
            ),
          );
        }
      });
      
      // 자동 저장
      await widget.repo.put(_session);
      
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context, 
          AppLocalizations.of(context).exerciseAdded,
        );
      }
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completedSets = _session.exercises.fold<int>(
      0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    final totalSets = _session.exercises.fold<int>(
      0, (sum, e) => sum + e.sets.length);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Stack(
        children: [
          Scaffold(
            // backgroundColor removed - uses theme default (pure black)
            body: SafeArea(
              child: Column(
                children: [
                  // 상단 헤더
                  _buildHeader(l10n, completedSets, totalSets),
                  
                  // 액션 바 (모두 접기/펼치기 + 순서 변경)
                  _buildActionBar(l10n),
                  
                  // 운동 목록
                  Expanded(
                    child: _buildExerciseList(l10n),
                  ),
                ],
              ),
            ),
            // 하단 바: 미니 플로팅 타이머가 표시될 때는 숨김
            bottomNavigationBar: (_restTimerRunning && _isTimerUIVisible && !_showRestTimerOverlay)
                ? null
                : _buildBottomBar(l10n),
          ),
          // 휴식 타이머: 전체 화면 또는 미니 플로팅 (UI가 표시될 때만)
          if (_restTimerRunning && _isTimerUIVisible)
            _showRestTimerOverlay 
                ? _buildFullScreenTimerOverlay(l10n)
                : _buildMiniFloatingTimer(l10n),
        ],
      ),
    );
  }
  
  /// 전체 화면 타이머 오버레이 (Industrial/Tactical Style)
  Widget _buildFullScreenTimerOverlay(AppLocalizations l10n) {
    final progress = _restSeconds / _defaultRestDuration;
    const accentColor = Color(0xFF00E5FF); // Electric Cyan
    
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF121212), // Deep dark background
        child: SafeArea(
          child: Stack(
            children: [
              // 좌측 상단 X 버튼 (Angular style)
              Positioned(
                top: 8,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isTimerUIVisible = false);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(8), // Angular
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // 메인 콘텐츠
              Column(
                children: [
                  const Spacer(flex: 2),
                  // Thin Ring Timer with Massive Typography
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Thin progress ring
                        CustomPaint(
                          size: const Size(320, 320),
                          painter: _TimerRingPainter(
                            progress: progress.clamp(0.0, 1.0),
                            strokeWidth: 4, // Thin and sharp
                            backgroundColor: const Color(0xFF2C2C2E),
                            progressColor: accentColor,
                          ),
                        ),
                        // Massive monospace timer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Label
                            Text(
                              'REST',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[600],
                                letterSpacing: 2.0,
                                fontFamily: 'Courier',
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Timer (HUGE)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatTime(_restSeconds),
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  letterSpacing: 4,
                                  fontFamily: 'Courier',
                                  decoration: TextDecoration.none,
                                  shadows: [
                                    Shadow(
                                      color: accentColor.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // 시간 조절 버튼들 (Angular Machine Interface)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTacticalTimeButton(-60, '-1M'),
                      const SizedBox(width: 12),
                      _buildTacticalTimeButton(-10, '-10'),
                      const SizedBox(width: 12),
                      _buildTacticalTimeButton(10, '+10'),
                      const SizedBox(width: 12),
                      _buildTacticalTimeButton(60, '+1M'),
                    ],
                  ),
                  const Spacer(flex: 2),
                  // 하단 메인 버튼 (Outlined style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _restTimer?.cancel();
                        setState(() => _restTimerRunning = false);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: accentColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: accentColor,
                      ),
                      child: Text(
                        l10n.skipRest.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'Courier',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 미니 플로팅 타이머 → 하단 고정 바 스타일 (Industrial)
  Widget _buildMiniFloatingTimer(AppLocalizations l10n) {
    final progress = _restSeconds / _defaultRestDuration;
    const accentColor = Color(0xFF00E5FF); // Electric Cyan
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF121212), // Deep dark
          border: Border(top: BorderSide(color: Color(0xFF2C2C2C), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단: 프로그레스 + 시간 + X버튼
              Row(
                children: [
                  // 미니 Thin Ring
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CustomPaint(
                      painter: _TimerRingPainter(
                        progress: progress.clamp(0.0, 1.0),
                        strokeWidth: 3,
                        backgroundColor: const Color(0xFF2C2C2E),
                        progressColor: accentColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.timer_outlined,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 시간 표시 (Monospace)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REST',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            fontFamily: 'Courier',
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          _formatTime(_restSeconds),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                            fontFamily: 'Courier',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // X 버튼 (Angular)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isTimerUIVisible = false);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 시간 조절 버튼들 (Angular)
              Row(
                children: [
                  _buildMiniTimeButton(-60, '-1M'),
                  const SizedBox(width: 8),
                  _buildMiniTimeButton(-10, '-10'),
                  const SizedBox(width: 8),
                  _buildMiniTimeButton(10, '+10'),
                  const SizedBox(width: 8),
                  _buildMiniTimeButton(60, '+1M'),
                ],
              ),
              const SizedBox(height: 12),
              // 스킵 버튼 (Outlined)
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _restTimer?.cancel();
                  setState(() => _restTimerRunning = false);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: accentColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: accentColor,
                ),
                child: Text(
                  l10n.skipRest.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'Courier',
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 미니 타이머용 시간 조절 버튼 (Angular Machine Interface)
  Widget _buildMiniTimeButton(int seconds, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _restSeconds = (_restSeconds + seconds).clamp(1, 600);
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(8), // Angular
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Courier',
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 전체 화면용 Tactical 시간 조절 버튼
  Widget _buildTacticalTimeButton(int seconds, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _restSeconds = (_restSeconds + seconds).clamp(1, 600);
        });
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12), // Angular, not circle
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Courier',
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, int completedSets, int totalSets) {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayName = weekDays[widget.date.weekday - 1];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.black, // Pure black
        border: Border(bottom: BorderSide(color: Colors.white12, width: 1)), // Divider
      ),
      child: Column(
        children: [
          // Date label (small, grey)
          Text(
            '${widget.date.month}/${widget.date.day} ($dayName)',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontFamily: 'Courier',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Main Dashboard Row (Balanced sizes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Timer (Reduced by 20% - was 52, now 42)
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 42, // Reduced from 52
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Courier', // Monospace
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 24),
              // Set Progress (Same size as timer for balance)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETS',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Courier',
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedSets / $totalSets',
                    style: const TextStyle(
                      fontSize: 42, // Same as timer for balance
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2196F3), // Iron Blue
                      fontFamily: 'Courier',
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 액션 바 (섹션 헤더 스타일)
  Widget _buildActionBar(AppLocalizations l10n) {
    final exerciseCount = _session.exercises.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 왼쪽: 섹션 제목
          Text(
            '${l10n.exerciseList} ($exerciseCount)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // 오른쪽: 버튼 그룹
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _allCardsExpanded = !_allCardsExpanded);
            },
            child: Icon(
              _allCardsExpanded ? Icons.unfold_less : Icons.unfold_more,
              size: 22,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showReorderModal(l10n),
            child: const Icon(
              Icons.swap_vert,
              size: 22,
              color: Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 순서 변경 모달
  void _showReorderModal(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReorderExercisesModal(
        exercises: _session.exercises,
        onReorder: (newOrder) {
          setState(() {
            _session.exercises.clear();
            _session.exercises.addAll(newOrder);
          });
        },
      ),
    );
  }


  Widget _buildExerciseList(AppLocalizations l10n) {
    // 미니 타이머가 표시될 때 하단 패딩 추가 (하단 바 높이만큼)
    final bottomPadding = (_restTimerRunning && _isTimerUIVisible && !_showRestTimerOverlay) ? 200.0 : 8.0;
    
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final exercise = _session.exercises[index];
              return Dismissible(
                key: ValueKey('${exercise.name}_dismiss_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (direction) {
                  final deletedExercise = exercise;
                  setState(() {
                    _session.exercises.removeAt(index);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${deletedExercise.name} 삭제됨'),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: '실행 취소',
                        onPressed: () {
                          setState(() {
                            _session.exercises.insert(index, deletedExercise);
                          });
                        },
                      ),
                    ),
                  );
                },
                child: ExerciseCard(
                  key: ValueKey('${exercise.name}_card_$index'),
                  exercise: exercise,
                  exerciseIndex: index,
                  onDelete: () {
                    setState(() {
                      _session.exercises.removeAt(index);
                    });
                  },
                  onUpdate: () => setState(() {}),
                  onSetCompleted: _onSetChecked,
                  isWorkoutStarted: true,
                  isEditingEnabled: true,
                  forceExpanded: _allCardsExpanded,
                  sessionRepo: widget.repo, // SessionRepo 전달
                  exerciseRepo: widget.exerciseRepo, // ExerciseLibraryRepo 전달
                ),
              );
            },
            childCount: _session.exercises.length,
          ),
        ),
        // 운동 추가 버튼을 SliverToBoxAdapter로 추가
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: _buildAddExerciseButton(l10n),
          ),
        ),
      ],
    );
  }
  
  /// 운동 추가 버튼 (리스트 맨 아래)
  Widget _buildAddExerciseButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: _addExercise,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3A3A3C),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey[400],
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.addExercise,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    const accentColor = Color(0xFF00E5FF); // Electric Cyan
    const dangerColor = Color(0xFFFF453A); // Crimson Red
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40), // Safe area bottom padding included
      decoration: const BoxDecoration(
        color: Colors.black, // Merge with background
        border: Border(top: BorderSide(color: Colors.white10, width: 1)), // Subtle separator
      ),
      child: Row(
        children: [
          // 1. Rest Timer (The Main Tool) - Dominant space
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                // 타이머가 실행 중이면 UI 다시 표시, 아니면 설정 모달
                if (_restTimerRunning) {
                  setState(() => _isTimerUIVisible = true);
                } else {
                  _showRestTimeSettings();
                }
              },
              onLongPress: _showRestTimeSettings, // 길게 누르면 항상 설정 모달
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _restTimerRunning 
                      ? const Color(0xFF1A2A2A) // Dark cyan tint when active
                      : const Color(0xFF1C1C1E), // Solid Gunmetal Grey
                  borderRadius: BorderRadius.circular(12),
                  border: _restTimerRunning 
                      ? Border.all(color: accentColor.withValues(alpha: 0.5), width: 1)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      color: _restTimerRunning ? accentColor : accentColor.withValues(alpha: 0.7), 
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _restTimerRunning 
                          ? _formatTime(_restSeconds)
                          : _formatTime(_defaultRestDuration),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontFamily: 'Courier', // Monospace for numbers
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2. Finish Button (The Exit Door) - Compact space
          Expanded(
            flex: 1,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2C1C1C), // Very dark red background (Subtle)
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dangerColor.withValues(alpha: 0.3), // Subtle border
                  width: 1,
                ),
              ),
              child: TextButton(
                onPressed: _finishWorkout,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.endWorkout, // Short & Clear (종료)
                  style: const TextStyle(
                    color: dangerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimeSettings() {
    final TextEditingController timeController = TextEditingController(
      text: _defaultRestDuration.toString(),
    );
    bool showOverlay = _showRestTimerOverlay;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFF2196F3)),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).restTimeSettings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (_restTimerRunning)
                    TextButton(
                      onPressed: () {
                        _restTimer?.cancel();
                        setState(() => _restTimerRunning = false);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context).cancelTimer,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // 시간 조절
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      int current = int.tryParse(timeController.text) ?? 90;
                      current = (current - 10).clamp(10, 600);
                      timeController.text = current.toString();
                      setModalState(() {});
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          Text('초', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      int current = int.tryParse(timeController.text) ?? 90;
                      current = (current + 10).clamp(10, 600);
                      timeController.text = current.toString();
                      setModalState(() {});
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 프리셋
              Row(
                children: [60, 90, 120, 180].map((sec) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          timeController.text = sec.toString();
                          setModalState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          sec >= 60 ? '${sec ~/ 60}분${sec % 60 > 0 ? '${sec % 60}초' : ''}' : '$sec초',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // 화면에 표시 옵션
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).showOnScreen,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).showOnScreenDescription,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: showOverlay,
                      onChanged: (value) {
                        setModalState(() => showOverlay = value);
                      },
                      activeColor: const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newDuration = int.tryParse(timeController.text) ?? 90;
                    setState(() {
                      _defaultRestDuration = newDuration.clamp(10, 600);
                      _showRestTimerOverlay = showOverlay;
                      if (_restTimerRunning) {
                        _restSeconds = _defaultRestDuration;
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    AppLocalizations.of(context).confirm,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 세련된 원형 프로그레스 링 페인터
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _TimerRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원 (어두운 회색)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행 원 (오렌지)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2, // 12시 방향에서 시작
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 운동 순서 변경 모달
class _ReorderExercisesModal extends StatefulWidget {
  final List<Exercise> exercises;
  final Function(List<Exercise>) onReorder;

  const _ReorderExercisesModal({
    required this.exercises,
    required this.onReorder,
  });

  @override
  State<_ReorderExercisesModal> createState() => _ReorderExercisesModalState();
}

class _ReorderExercisesModalState extends State<_ReorderExercisesModal> {
  late List<Exercise> _tempExercises;

  @override
  void initState() {
    super.initState();
    _tempExercises = List.from(widget.exercises);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 화면 높이의 동적 계산 (운동 개수에 따라 최소 40%, 최대 70%)
    final screenHeight = MediaQuery.of(context).size.height;
    final itemCount = _tempExercises.length;
    final dynamicHeight = (0.15 + (itemCount * 0.08)).clamp(0.4, 0.7);
    
    return Container(
      height: screenHeight * dynamicHeight,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    l10n.reorderExercises,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      widget.onReorder(_tempExercises);
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 드래그 가능한 리스트
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _tempExercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _tempExercises.removeAt(oldIndex);
                    _tempExercises.insert(newIndex, item);
                  });
                  HapticFeedback.lightImpact();
                },
                itemBuilder: (context, index) {
                  final exercise = _tempExercises[index];
                  final completedSets = exercise.sets.where((s) => s.isCompleted).length;
                  final totalSets = exercise.sets.length;
                  
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(exercise),
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252932),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.drag_handle, color: Colors.grey[600], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${exercise.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$completedSets / $totalSets SET',
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

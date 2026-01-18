import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../data/session_repo.dart';
import '../../../data/exercise_library_repo.dart';
import '../../../models/session.dart';
import '../../../models/exercise.dart';
import '../../../models/exercise_set.dart';
import '../widgets/exercise_card.dart';
import '../../../core/error_handler.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n_extensions.dart';
import '../../../services/ad_service.dart';
import '../../../shared/utils/time_format.dart';
import 'exercise_selection_page.dart';

/// 운동 중 전체 화면 모달 (탭바 숨김, 집중 모드)
class ActiveWorkoutPage extends StatefulWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final DateTime date;
  final bool isEditing; // Edit mode flag

  const ActiveWorkoutPage({
    super.key,
    required this.session,
    required this.repo,
    required this.exerciseRepo,
    required this.date,
    this.isEditing = false,
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
  
  // 💰 광고 서비스
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    
    debugPrint('🔍 [ActiveWorkoutPage] initState called');
    debugPrint('🔍 [ActiveWorkoutPage] isEditing: ${widget.isEditing}');
    debugPrint('🔍 [ActiveWorkoutPage] session.isCompleted: ${_session.isCompleted}');
    debugPrint('🔍 [ActiveWorkoutPage] session.durationInSeconds: ${_session.durationInSeconds}');
    
    // Edit 모드가 아닐 때만 타이머 시작
    if (!widget.isEditing) {
      debugPrint('🔍 [ActiveWorkoutPage] Starting workout timer (Active mode)');
      _startWorkoutTimer();
    } else {
      // Edit 모드: 저장된 시간 로드
      debugPrint('🔍 [ActiveWorkoutPage] Loading saved duration (Edit mode)');
      _elapsedSeconds = _session.durationInSeconds;
    }
    
    // 🎯 출시 모드에서만 광고 미리 로드
    if (!kDebugMode) {
      _adService.loadInterstitialAd();
    } else {
      if (kDebugMode) {
        print('🚀 개발 모드라 광고 로드를 스킵했습니다.');
      }
    }
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
    if (value && !widget.isEditing) {
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
                widget.isEditing 
                    ? '수정 완료' 
                    : (isCompleting ? l10n.finishWorkoutTitle : l10n.endWorkout),
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
                      value: formatDuration(_elapsedSeconds),
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
                    widget.isEditing 
                        ? '저장' 
                        : (isCompleting ? l10n.finishWorkout : l10n.confirm),
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
    
    // Always mark as completed (both in active and edit mode)
    _session.isCompleted = true;
    _session.durationInSeconds = _elapsedSeconds;
    
    await widget.repo.put(_session);
    
    HapticFeedback.heavyImpact();
    
    if (mounted) {
      ErrorHandler.showSuccessSnackBar(
        context, 
        widget.isEditing ? '수정 완료' : context.l10n.workoutCompleted,
      );
      
      // Skip ads in edit mode or debug mode
      if (widget.isEditing || kDebugMode) {
        if (kDebugMode) {
          print('🚀 개발 모드 또는 수정 모드라 광고를 스킵했습니다.');
        }
        Navigator.of(context).pop(true);
      } else {
        // 출시 모드: 광고 표시 후 홈으로 이동
        await _adService.showInterstitialAd(
          onAdClosed: () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          },
        );
      }
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
        builder: (_) => const ExerciseSelectionPage(),
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
    _adService.dispose(); // 광고 리소스 정리
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
  
  /// 전체 화면 타이머 오버레이 (Retro-Terminal/Raw Data Style)
  Widget _buildFullScreenTimerOverlay(AppLocalizations l10n) {
    return Positioned.fill(
      child: Container(
        color: Colors.black, // Pure black background
        child: SafeArea(
          child: Stack(
            children: [
              // 좌측 상단 X 버튼
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
                      border: Border.all(color: Colors.white24, width: 1),
                      borderRadius: BorderRadius.circular(4),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Header Label
                      Text(
                        'REST PERIOD',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 2. The Timer (Massive, Monospace, No Circle)
                      Text(
                        formatDuration(_restSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                          decoration: TextDecoration.none,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 3. Dashed Divider (The "Receipt" Look)
                      Text(
                        '- - - - - - - - - - - - - - - - - - - - - -',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.15),
                          letterSpacing: 2,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      const SizedBox(height: 32),
                      // 4. Adjust Buttons (Raw Text Style)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTerminalTimeButton(-60, '-1M'),
                          _buildTerminalTimeButton(-10, '-10'),
                          _buildTerminalTimeButton(10, '+10'),
                          _buildTerminalTimeButton(60, '+1M'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // 5. Skip Button (Matches Calendar Button style)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _restTimer?.cancel();
                            setState(() => _restTimerRunning = false);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.03),
                            foregroundColor: Colors.white,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 미니 플로팅 타이머 → 하단 고정 바 스타일 (Retro-Terminal)
  Widget _buildMiniFloatingTimer(AppLocalizations l10n) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header + Close
              Row(
                children: [
                  Text(
                    'REST PERIOD',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontFamily: 'Courier',
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isTimerUIVisible = false);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Massive Timer
              Text(
                formatDuration(_restSeconds),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Courier',
                  letterSpacing: -1.0,
                  decoration: TextDecoration.none,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              // Dashed Divider
              Text(
                '- - - - - - - - - - - - - - - - - - - - - -',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.15),
                  letterSpacing: 2,
                  fontFamily: 'Courier',
                  fontSize: 10,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              const SizedBox(height: 12),
              // 시간 조절 버튼들
              Row(
                children: [
                  _buildMiniTerminalButton(-60, '-1M'),
                  const SizedBox(width: 8),
                  _buildMiniTerminalButton(-10, '-10'),
                  const SizedBox(width: 8),
                  _buildMiniTerminalButton(10, '+10'),
                  const SizedBox(width: 8),
                  _buildMiniTerminalButton(60, '+1M'),
                ],
              ),
              const SizedBox(height: 12),
              // 스킵 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _restTimer?.cancel();
                    setState(() => _restTimerRunning = false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.03),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    l10n.skipRest.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontFamily: 'Courier',
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 미니 타이머용 Terminal 스타일 버튼
  Widget _buildMiniTerminalButton(int seconds, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _restSeconds = (_restSeconds + seconds).clamp(1, 600);
          });
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
  
  /// 전체 화면용 Terminal 스타일 시간 조절 버튼
  Widget _buildTerminalTimeButton(int seconds, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _restSeconds = (_restSeconds + seconds).clamp(1, 600);
        });
      },
      child: Container(
        width: 72,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white.withValues(alpha: 0.03),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
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
                formatDuration(_elapsedSeconds),
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
  
  /// 운동 추가 버튼 (리스트 맨 아래) - Ghost Style
  Widget _buildAddExerciseButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50, // Slightly more compact
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent, // Ghost Style
            side: const BorderSide(color: Colors.white24, width: 1), // Thin Wireframe
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // Sharp
            ),
            foregroundColor: Colors.white, // Splash Color
          ),
          onPressed: _addExercise,
          icon: Icon(
            Icons.add,
            size: 18,
            color: Colors.grey[600],
          ),
          label: Text(
            l10n.addExercise,
            style: TextStyle(
              fontFamily: 'Courier', // The Iron Log Font
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600], // Subtle text
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    const dangerColor = Color(0xFFFF453A); // Crimson Red
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Row(
        children: [
          // 1. Timer Button (Calendar Ghost Style) - Takes most space
          Expanded(
            child: InkWell(
              onTap: () {
                // 타이머가 실행 중이면 UI 다시 표시, 아니면 설정 모달
                if (_restTimerRunning) {
                  setState(() => _isTimerUIVisible = true);
                } else {
                  _showRestTimeSettings();
                }
              },
              onLongPress: _showRestTimeSettings,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.transparent, // Ghost
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 1), // Calendar Border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _restTimerRunning 
                          ? formatDuration(_restSeconds)
                          : formatDuration(_defaultRestDuration),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Gap
          // 2. End Button (Icon Only) - Wider for easier tapping
          InkWell(
            onTap: _finishWorkout,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80, // Wider than square for better tap target
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent, // Ghost
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.stop_circle_outlined,
                  color: dangerColor, // Red Icon
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestTimeSettings() {
    int currentValue = _defaultRestDuration;
    bool showOverlay = _showRestTimerOverlay;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black, // Terminal Background
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)), // Sharp
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              Text(
                'SET REST DURATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 30),
              // 2. Main Machine Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minus Button
                  _buildSquareIconBtn(
                    Icons.remove,
                    () {
                      setModalState(() {
                        currentValue = (currentValue - 10).clamp(10, 600);
                      });
                    },
                  ),
                  const SizedBox(width: 24),
                  // Value Display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentValue.toString(),
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'SECONDS',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 10,
                          fontFamily: 'Courier',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Plus Button
                  _buildSquareIconBtn(
                    Icons.add,
                    () {
                      setModalState(() {
                        currentValue = (currentValue + 10).clamp(10, 600);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // 3. Preset Grid (Rectangular)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildPresetBtn('60', currentValue == 60, () {
                    setModalState(() => currentValue = 60);
                  }),
                  _buildPresetBtn('90', currentValue == 90, () {
                    setModalState(() => currentValue = 90);
                  }),
                  _buildPresetBtn('120', currentValue == 120, () {
                    setModalState(() => currentValue = 120);
                  }),
                  _buildPresetBtn('180', currentValue == 180, () {
                    setModalState(() => currentValue = 180);
                  }),
                ],
              ),
              const SizedBox(height: 30),
              // 4. Visual Toggle (Styled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SHOW ON SCREEN',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: 'Courier',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Switch(
                      value: showOverlay,
                      onChanged: (value) {
                        setModalState(() => showOverlay = value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.grey[700],
                      inactiveThumbColor: Colors.grey[600],
                      inactiveTrackColor: Colors.grey[800],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // 5. Confirm Button (Tactical)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // High Contrast
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _defaultRestDuration = currentValue;
                      _showRestTimerOverlay = showOverlay;
                      if (_restTimerRunning) {
                        _restSeconds = _defaultRestDuration;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              // Cancel Timer Button (if running)
              if (_restTimerRunning) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _restTimer?.cancel();
                    setState(() => _restTimerRunning = false);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CANCEL TIMER',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Courier',
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Square Buttons
  Widget _buildSquareIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // Helper for Presets
  Widget _buildPresetBtn(String seconds, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontFamily: 'Courier',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
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

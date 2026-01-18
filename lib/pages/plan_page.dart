import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../core/error_handler.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_extensions.dart';
import '../widgets/tempo_settings_modal.dart';
import '../widgets/tempo_countdown_modal.dart';
import '../widgets/modern_workout_card.dart';
import '../services/tempo_controller.dart';
import 'exercise_selection_page_v2.dart';

/// 운동 계획 페이지 - 완전 리팩토링 버전
class PlanPage extends StatefulWidget {
  final DateTime date;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final bool isFromTodayWorkout;
  final bool isViewOnly; // 완료된 운동 조회 모드
  
  const PlanPage({
    super.key,
    required this.date,
    required this.repo,
    required this.exerciseRepo,
    this.isFromTodayWorkout = false,
    this.isViewOnly = false,
  });

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  Session? _currentSession;
  bool _isLoading = true;
  Set<String> _workoutDates = {};
  bool _isEditingMode = false; // 편집 모드 플래그
  
  // Live Workout Mode
  bool _isWorkoutStarted = false;
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  bool _restTimerRunning = false;
  int _defaultRestDuration = 90; // 기본 휴식 시간

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _focusedDate = widget.date;
    _loadSession();
    _loadWorkoutDates();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final session = await widget.repo.get(widget.repo.ymd(_selectedDate));
      if (mounted) {
        setState(() {
          _currentSession = session;
          _isLoading = false;
        });
        
        // 캘린더에서 "운동 시작" 버튼으로 진입한 경우 자동으로 운동 시작
        if (widget.isFromTodayWorkout && !widget.isViewOnly && !_isWorkoutStarted) {
          if (_currentSession != null && 
              _currentSession!.isWorkoutDay && 
              _currentSession!.exercises.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _startWorkout();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(context, '세션 로드 실패: $e');
      }
    }
  }

  Future<void> _loadWorkoutDates() async {
    try {
      final sessions = await widget.repo.getWorkoutSessions();
      if (mounted) {
        setState(() {
          _workoutDates = sessions.map((s) => s.ymd).toSet();
        });
      }
    } catch (e) {
      // 무시
    }
  }

  void _onDateSelected(DateTime date) {
    // 오늘의 운동에서 진입한 경우:
    // - 운동이 완료되지 않은 경우: 날짜 변경 불가
    // - 운동이 완료된 경우 (isViewOnly): 날짜 변경 가능 (편집 모드)
    if (widget.isFromTodayWorkout && !widget.isViewOnly) {
      ErrorHandler.showErrorSnackBar(context, context.l10n.cannotChangeDateDuringWorkout);
      return;
    }
    
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
    });
    _loadSession();
  }

  void _onWeekChanged(DateTime newWeekStart) {
    setState(() {
      _focusedDate = newWeekStart;
    });
  }

  Future<void> _saveSession() async {
    final session = _currentSession;
    if (session != null) {
      try {
        await widget.repo.put(session);
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, context.l10n.saved);
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, '저장 실패: $e');
        }
      }
    }
  }

  Future<void> _markRest() async {
    final isRest = !(_currentSession?.isRest ?? false);

    if (isRest &&
        _currentSession != null &&
        _currentSession!.exercises.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('운동 기록 삭제', style: TextStyle(color: Colors.white)),
          content: const Text('휴식일로 설정하면 작성한 운동 계획이 삭제됩니다.\n계속하시겠습니까?',
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context).cancel)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context).confirm, style: const TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirm != true) return;
    }

    try {
      await widget.repo.markRest(widget.repo.ymd(_selectedDate), rest: isRest);
      await _loadSession(); // Reload session to reflect changes
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
            context, isRest ? context.l10n.restDaySet : context.l10n.restDayUnset);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, '오류 발생: $e');
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _saveSession();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isWorkoutStarted) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          '운동 종료',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '운동을 종료하시겠습니까?\n진행 상황은 저장됩니다.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              _finishWorkout();
              Navigator.pop(context, true);
            },
            child: const Text('종료', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isWorkoutStarted,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // backgroundColor removed - uses theme default (pure black)
        appBar: AppBar(
          title: const Text('운동 계획'),
          // backgroundColor removed - uses theme default
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_isWorkoutStarted) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (!_isWorkoutStarted)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rest') {
                    _markRest();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rest',
                    child: Text(_currentSession?.isRest == true
                        ? '휴식 취소'
                        : '운동 휴식하기'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
        body: Column(
          children: [
            // 1. Top: 운동 중이면 간단한 날짜 표시, 아니면 캘린더
            if (_isWorkoutStarted)
              _buildWorkoutDateHeader()
            else
              _buildCompactWeeklyCalendar(),
          
          // 2. Middle: Exercise List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentSession == null || !_currentSession!.isWorkoutDay
                    ? _buildEmptyState()
                    : _buildExerciseList(),
          ),
        ],
      ),
      // 3. Bottom: Fixed Action Bar (상태에 따라 교체)
      bottomNavigationBar: _isWorkoutStarted
          ? _buildLiveWorkoutBar()
          : _buildActionBar(),
      ),
    );
  }

  // 1. Compact Weekly Calendar (모바일 최적화)
  Widget _buildCompactWeeklyCalendar() {
    final startOfWeek = _focusedDate.subtract(
      Duration(days: _focusedDate.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 좌측 화살표
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: (widget.isFromTodayWorkout && !widget.isViewOnly) ? null : () {
              final previousWeek = _focusedDate.subtract(const Duration(days: 7));
              _onWeekChanged(previousWeek);
              _onDateSelected(previousWeek);
            },
          ),
          // 날짜들
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((day) {
                final isSelected = day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                final hasWorkout = _workoutDates.contains(widget.repo.ymd(day));
                
                return GestureDetector(
                  onTap: (widget.isFromTodayWorkout && !widget.isViewOnly) ? null : () => _onDateSelected(day),
                  child: Container(
                    width: 36,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.white,
                          ),
                        ),
                        if (hasWorkout && !isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2196F3),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 우측 화살표
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: (widget.isFromTodayWorkout && !widget.isViewOnly) ? null : () {
              final nextWeek = _focusedDate.add(const Duration(days: 7));
              _onWeekChanged(nextWeek);
              _onDateSelected(nextWeek);
            },
          ),
        ],
      ),
    );
  }

  // 운동 중일 때 표시되는 간단한 날짜 헤더
  Widget _buildWorkoutDateHeader() {
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayName = weekDays[_selectedDate.weekday - 1];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF2196F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedDate.month}월 ${_selectedDate.day}일 ($dayName) 운동 중',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_currentSession?.exercises.length ?? 0}개 운동',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          // 캘린더 보기 버튼 (필요시 펼치기)
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
            onPressed: () {
              // 운동 종료 확인 없이 캘린더만 잠시 보여주기
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E1E),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '운동 중에는 날짜를 변경할 수 없습니다',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context).confirm),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_currentSession?.isRest == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hotel, size: 64, color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            const Text(
              '오늘은 휴식일입니다',
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '충분한 휴식은 근성장에 필수적입니다!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            '운동 계획이 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '하단의 "운동 추가" 버튼을 눌러\n운동을 추가해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false, // 드래그 핸들 아이콘 제거
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _currentSession!.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _currentSession!.exercises[index];
        return ReorderableDragStartListener(
          key: ValueKey(exercise),
          index: index,
          child: ModernWorkoutCard(
            exercise: exercise,
            exerciseIndex: index,
            onDelete: () {
              setState(() {
                _currentSession!.exercises.removeAt(index);
              });
            },
            onUpdate: () {
              setState(() {});
            },
            onSetCompleted: _onSetChecked,
            isWorkoutStarted: _isWorkoutStarted,
            isEditingEnabled: !widget.isViewOnly || _isEditingMode, // 편집 활성화 여부
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _currentSession!.exercises.removeAt(oldIndex);
          _currentSession!.exercises.insert(newIndex, item);
          HapticFeedback.mediumImpact();
        });
      },
      // Visual Feedback during Drag (Apple-style)
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double elevation = Tween<double>(
              begin: 0,
              end: 8,
            ).evaluate(animation);
            
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  // 3. Bottom Action Bar (Balance - 4:6 비율, 52px 고정)
  Widget _buildActionBar() {
    final hasExercises = _currentSession != null && 
                        _currentSession!.isWorkoutDay && 
                        _currentSession!.exercises.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 좌측 (40%): 운동 추가 버튼 (편집 모드에서만 표시)
            if (!widget.isViewOnly || _isEditingMode)
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 52, // 고정 높이
                  child: OutlinedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      '운동 추가',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            if (!widget.isViewOnly || _isEditingMode)
              const SizedBox(width: 12),
            // 우측: 운동 시작 / 운동 편집 / 편집 완료 버튼
            Expanded(
              flex: widget.isViewOnly && !_isEditingMode ? 12 : 6,
              child: SizedBox(
                height: 52, // 고정 높이
                child: ElevatedButton.icon(
                  onPressed: hasExercises ? (
                    widget.isViewOnly 
                      ? (_isEditingMode ? _finishEditingWorkout : _startEditingMode)
                      : _startWorkout
                  ) : null,
                  icon: Icon(
                    widget.isViewOnly 
                      ? (_isEditingMode ? Icons.check : Icons.edit)
                      : Icons.play_arrow,
                    size: 22,
                  ),
                  label: Text(
                    widget.isViewOnly 
                      ? (_isEditingMode ? context.l10n.editComplete : context.l10n.editWorkout)
                      : context.l10n.startWorkout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isViewOnly 
                      ? const Color(0xFF34C759)  // 초록색 (편집 모드)
                      : const Color(0xFF2196F3), // 파란색 (시작 모드)
                    disabledBackgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    final selected = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseSelectionPageV2(),
      ),
    );

    if (selected != null && selected.isNotEmpty && mounted) {
      setState(() {
        if (_currentSession == null || _currentSession!.isRest) {
          _currentSession = Session(
            ymd: widget.repo.ymd(_selectedDate),
            exercises: selected,
            isRest: false,
          );
        } else {
          _currentSession!.exercises.addAll(selected);
        }
      });
      await _saveSession();
      await _loadWorkoutDates();
    }
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
      _elapsedSeconds = 0;
      _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _elapsedSeconds++);
        }
      });
    });
    HapticFeedback.mediumImpact();
  }

  void _finishWorkout() async {
    final session = _currentSession;
    if (session == null) return;
    
    // 미완료 세트가 있는지 확인
    final hasIncompleteSets = session.exercises.any((e) =>
        e.sets.any((s) => !s.isCompleted));
    
    if (hasIncompleteSets) {
      // 경고 팝업 표시
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            context.l10n.workoutCompletedTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            context.l10n.incompleteSetWarning,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).done),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }
    
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    // 세션을 완료 상태로 설정
    if (_currentSession != null) {
      _currentSession!.isCompleted = true;
    }
    
    setState(() {
      _isWorkoutStarted = false;
      _restTimerRunning = false;
      _elapsedSeconds = 0;
      _restSeconds = 0;
    });
    _saveSession();
    HapticFeedback.heavyImpact();
    ErrorHandler.showSuccessSnackBar(context, context.l10n.workoutCompleted);
  }

  void _finishEditingWorkout() {
    // 편집 완료 - 타이머 없이 저장만 함
    _saveSession();
    setState(() {
      _isEditingMode = false;
    });
    HapticFeedback.mediumImpact();
    ErrorHandler.showSuccessSnackBar(context, context.l10n.editCompleted);
    Navigator.of(context).pop();
  }

  void _startEditingMode() {
    // 편집 모드 활성화
    setState(() {
      _isEditingMode = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _onSetChecked(bool value) {
    if (value && _isWorkoutStarted) {
      _startRestTimer(_defaultRestDuration);
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

  void _showRestTimeSettings() {
    final TextEditingController timeController = TextEditingController(
      text: _defaultRestDuration.toString(),
    );
    
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
            left: 20,
            right: 20,
            top: 20,
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
                  const Text(
                    '휴식 시간 설정',
                    style: TextStyle(
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
                      child: const Text('타이머 취소', style: TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 직접 입력
              Row(
                children: [
                  // -10초 버튼
                  IconButton(
                    onPressed: () {
                      int current = int.tryParse(timeController.text) ?? 90;
                      current = (current - 10).clamp(10, 600);
                      timeController.text = current.toString();
                      setModalState(() {});
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                  ),
                  // 입력 필드
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
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Text(
                            '초',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // +10초 버튼
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
              
              // 프리셋 버튼들
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
              
              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newDuration = int.tryParse(timeController.text) ?? 90;
                    setState(() {
                      _defaultRestDuration = newDuration.clamp(10, 600);
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
                  child: Text(AppLocalizations.of(context).confirm, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Live Workout Bar (Image 2 Style)
  Widget _buildLiveWorkoutBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left Side (Timer Info) - Flex 4
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: _showRestTimeSettings,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _restTimerRunning ? "휴식" : "휴식",
                            style: TextStyle(
                              fontSize: 10,
                              color: _restTimerRunning ? const Color(0xFF4CAF50) : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _restTimerRunning ? "$_restSeconds s" : "${_defaultRestDuration}s",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _restTimerRunning ? const Color(0xFF4CAF50) : Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[700],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "TIME",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Side (Finish Button) - Flex 6
            Expanded(
              flex: 6,
              child: SizedBox(
                height: double.infinity,
                child: ElevatedButton(
                  onPressed: _finishWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.endWorkout,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 운동 카드 위젯 (이미지 Pixel Perfect 디자인)
class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final Function(bool)? onSetCompleted;
  final bool isWorkoutStarted;
  final bool isEditingEnabled; // 편집 활성화 여부

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
    this.onSetCompleted,
    this.isWorkoutStarted = false,
    this.isEditingEnabled = true,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final TextEditingController _memoController = TextEditingController();
  bool _isExpanded = true; // Default: Open
  TempoController? _tempoController;
  TempoMode _currentMode = TempoMode.beep; // Default

  @override
  void dispose() {
    _memoController.dispose();
    _tempoController?.dispose();
    super.dispose();
  }

  void _showTempoSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TempoSettingsModal(
        exercise: widget.exercise,
        initialMode: _currentMode,
        onUpdate: () {
          setState(() {});
          widget.onUpdate();
        },
        onModeChanged: (mode) {
          setState(() {
            _currentMode = mode;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 총 볼륨 계산
    final totalVolume = widget.exercise.sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );
    
    // 완료된 세트 수 계산
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF252932),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section (Unified Touch Zone: Tap = Expand, Long Press = Drag)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              HapticFeedback.lightImpact();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _buildHeader(totalVolume, completedSets, totalSets),
            ),
          ),
          
          // 2. Body Section (Collapsible with Animation)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(), // Collapsed State
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                
                // Memo Field
                _buildMemoField(),
                const SizedBox(height: 8),
                
                // Grid Layout - Column Headers
                _buildColumnHeaders(),
                const SizedBox(height: 6),
                
                // Set Rows
                ...List.generate(
                  widget.exercise.sets.length,
                  (index) => _SetRowGrid(
                    exercise: widget.exercise,
                    setIndex: index,
                    onDelete: () {
                      if (widget.exercise.sets.length > 1) {
                        setState(() {
                          widget.exercise.sets.removeAt(index);
                        });
                        widget.onUpdate();
                      } else {
                        ErrorHandler.showInfoSnackBar(
                          context,
                          '최소 1개의 세트가 필요합니다',
                        );
                      }
                    },
                    onUpdate: widget.onUpdate,
                    onSetCompleted: widget.onSetCompleted,
                    isWorkoutStarted: widget.isWorkoutStarted,
                    isEditingEnabled: widget.isEditingEnabled, // 편집 활성화 여부
                  ),
                ),
                const SizedBox(height: 8),
                
                // Footer Actions
                _buildFooterActions(),
              ],
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutQuart, // Apple-style smooth curve
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double totalVolume, int completedSets, int totalSets) {
    // Completion Logic
    final bool isCompleted = completedSets > 0 && completedSets == totalSets;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row (Always Visible) - 🎯 COMPACT SINGLE LINE
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1️⃣ Index (Simple Grey Text - NO BOX)
            Text(
              '${widget.exerciseIndex + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 12),
            
            // 2️⃣ Muscle Tag (Small Chip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.exercise.bodyPart,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // 3️⃣ Exercise Name (Dynamic Expansion) 🎯 MAGIC HAPPENS HERE
            Expanded(
              child: Text(
                widget.exercise.name,
                maxLines: _isExpanded ? null : 1, // 🔥 Dynamic!
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 🔥 Dynamic!
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dynamic Status Widget (Completion or Progress)
            if (isCompleted)
              // ✅ All Completed: Blue Checkmark (Brand Color)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2196F3), // Brand Blue
                size: 28,
              )
            else ...[
              // 템포 버튼 (편집 모드에서만 활성화)
              GestureDetector(
                onTap: widget.isEditingEnabled ? () => _showTempoSettings() : null,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isEditingEnabled && widget.exercise.isTempoEnabled
                        ? const Color(0xFF2196F3).withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isEditingEnabled && widget.exercise.isTempoEnabled
                          ? const Color(0xFF2196F3)
                          : Colors.grey[600]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 12,
                        color: widget.isEditingEnabled && widget.exercise.isTempoEnabled
                            ? const Color(0xFF2196F3)
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.exercise.isTempoEnabled
                            ? '${widget.exercise.eccentricSeconds}/${widget.exercise.concentricSeconds}s'
                            : '템포',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isEditingEnabled && widget.exercise.isTempoEnabled
                              ? const Color(0xFF2196F3)
                              : Colors.grey[400],
                          fontWeight: widget.isEditingEnabled && widget.exercise.isTempoEnabled
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 세트 진행률 (항상 표시) - RIGHTMOST ELEMENT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? const Color(0xFF2196F3).withValues(alpha: 0.2)
                      : const Color(0xFF3A4452),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedSets / $totalSets',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? const Color(0xFF2196F3) : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // Secondary Info (Progressive Disclosure - Only when Expanded)
        if (_isExpanded) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '총 볼륨 ${totalVolume.toStringAsFixed(0)}kg',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMemoField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF323844),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: _memoController,
        enabled: widget.isEditingEnabled, // 편집 활성화 여부
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: '메모',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '세트',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'kg',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              context.l10n.repsUnit,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              context.l10n.completeLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    return Column(
      children: [
        // 템포 시작 버튼 (운동 시작 후 + 템포 활성화 시 + 편집 모드에서만)
        if (widget.isWorkoutStarted && widget.exercise.isTempoEnabled && widget.isEditingEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startTempoSet,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(
                '템포 시작 (${widget.exercise.eccentricSeconds}/${widget.exercise.concentricSeconds}s)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // 세트 추가/삭제 버튼 (편집 모드에서만 활성화)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: widget.isEditingEnabled ? () {
                if (widget.exercise.sets.isNotEmpty) {
                  setState(() {
                    widget.exercise.sets.removeLast();
                  });
                  widget.onUpdate();
                }
              } : null,
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('세트 삭제', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: widget.isEditingEnabled ? Colors.grey[500] : Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: Colors.grey[700],
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            TextButton.icon(
              onPressed: widget.isEditingEnabled ? () {
                setState(() {
                  if (widget.exercise.sets.isNotEmpty) {
                    final lastSet = widget.exercise.sets.last;
                    widget.exercise.sets.add(ExerciseSet(
                      weight: lastSet.weight,
                      reps: lastSet.reps,
                    ));
                  } else {
                    widget.exercise.sets.add(ExerciseSet());
                  }
                });
                widget.onUpdate();
              } : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('세트 추가', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: widget.isEditingEnabled ? const Color(0xFF2196F3) : Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startTempoSet() async {
    // 완료되지 않은 첫 번째 세트 찾기
    final nextSetIndex = widget.exercise.sets.indexWhere((set) => !set.isCompleted);
    if (nextSetIndex == -1) {
      // 모든 세트 완료됨
      return;
    }

    final nextSet = widget.exercise.sets[nextSetIndex];
    if (nextSet.reps == 0) {
      // 횟수가 설정되지 않음
      ErrorHandler.showInfoSnackBar(context, '먼저 목표 횟수를 입력하세요');
      return;
    }

    // TempoController 초기화 및 시작
    _tempoController?.dispose();
    _tempoController = TempoController();
    _tempoController!.mode = _currentMode;
    
    await _tempoController!.init();
    
    // 모달 표시 후 템포 시작
    if (mounted) {
      showTempoCountdownModal(
        context: context,
        controller: _tempoController!,
        totalReps: nextSet.reps,
        downSeconds: widget.exercise.eccentricSeconds,
        upSeconds: widget.exercise.concentricSeconds,
        onComplete: () {
          // 세트 자동 완료
          if (mounted) {
            setState(() {
              nextSet.isCompleted = true;
            });
            widget.onUpdate();
            // 휴식 타이머 시작
            if (widget.onSetCompleted != null) {
              widget.onSetCompleted!(true);
            }
          }
        },
        onCancel: () {
          // 취소 시 컨트롤러 정리
          _tempoController?.stop();
        },
      );
      
      // 모달이 표시된 후 템포 시작
      await _tempoController!.start(
        reps: nextSet.reps,
        downSeconds: widget.exercise.eccentricSeconds,
        upSeconds: widget.exercise.concentricSeconds,
      );
    }
  }
}

/// Grid 레이아웃 세트 Row (High-Density UI)
class _SetRowGrid extends StatefulWidget {
  final Exercise exercise;
  final int setIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final Function(bool)? onSetCompleted;
  final bool isWorkoutStarted;
  final bool isEditingEnabled; // 편집 활성화 여부

  const _SetRowGrid({
    required this.exercise,
    required this.setIndex,
    required this.onDelete,
    required this.onUpdate,
    this.onSetCompleted,
    this.isWorkoutStarted = false,
    this.isEditingEnabled = true,
  });

  @override
  State<_SetRowGrid> createState() => _SetRowGridState();
}

class _SetRowGridState extends State<_SetRowGrid> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    final set = widget.exercise.sets[widget.setIndex];
    _weightController = TextEditingController(
      text: set.weight > 0 ? set.weight.toString() : '',
    );
    _repsController = TextEditingController(
      text: set.reps > 0 ? set.reps.toString() : '',
    );

    _weightController.addListener(_onWeightChanged);
    _repsController.addListener(_onRepsChanged);
  }

  void _onWeightChanged() {
    final newWeight = double.tryParse(_weightController.text) ?? 0.0;
    widget.exercise.sets[widget.setIndex].weight = newWeight;
    widget.onUpdate();
  }

  void _onRepsChanged() {
    final newReps = int.tryParse(_repsController.text) ?? 0;
    widget.exercise.sets[widget.setIndex].reps = newReps;
    widget.onUpdate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.exercise.sets[widget.setIndex];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4), // Ultra-Compact: 6 → 4px
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          // Set Number Badge (2) - Compact
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 26, // 28 → 26px
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4452),
                  borderRadius: BorderRadius.circular(5), // 6 → 5px
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.setIndex + 1}',
                  style: const TextStyle(
                    fontSize: 13, // 14 → 13px
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Weight Input (3) - Stack Style with Label
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _weightController,
              label: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              isEnabled: widget.isEditingEnabled,
            ),
          ),
          // Reps Input (3) - Stack Style with Label
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _repsController,
              label: context.l10n.repsUnit,
              keyboardType: TextInputType.number,
              isEnabled: widget.isEditingEnabled,
            ),
          ),
          // Conditional Action (2)
          Expanded(
            flex: 2,
            child: Center(
              child: widget.isWorkoutStarted
                  // 운동 중: 체크박스 (세트 완료)
                  ? Transform.scale(
                      scale: 0.85,
                      child: Checkbox(
                        value: set.isCompleted,
                        onChanged: (value) {
                          final isChecked = value ?? false;
                          setState(() {
                            set.isCompleted = isChecked;
                          });
                          widget.onUpdate();
                          if (isChecked && widget.onSetCompleted != null) {
                            widget.onSetCompleted!(isChecked);
                          }
                        },
                        activeColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  // 운동 시작 전: 삭제 버튼 (편집 모드에서만 활성화)
                  : IconButton(
                      onPressed: widget.isEditingEnabled ? widget.onDelete : null,
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Ultra-Compact Input (42px - Force Small)
  Widget _buildStackInput({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required bool isEnabled,
  }) {
    return Container(
      height: 42, // Force Compact: 48 → 42px
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: isEnabled ? const Color(0xFF2C2C2C) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6), // 8 → 6px
        border: Border.all(
          color: isEnabled ? Colors.grey.shade800 : Colors.grey.shade900,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // 1. Tiny Label (Tight Position)
          Positioned(
            top: 4, // 6 → 4px
            left: 8, // 10 → 8px
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10, // 11 → 10px
                color: isEnabled ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
          ),
          // 2. Centered Input (No Padding)
          Center(
            child: TextFormField(
              controller: controller,
              enabled: isEnabled,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, // 18 → 16px
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade600,
                height: 1.0, // Remove extra font padding
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8), // Fine-tune centering
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 세트 입력 Row
class SetRow extends StatefulWidget {
  final Exercise exercise;
  final int setIndex;
  final VoidCallback onDelete;

  const SetRow({
    super.key,
    required this.exercise,
    required this.setIndex,
    required this.onDelete,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    final set = widget.exercise.sets[widget.setIndex];
    _weightController = TextEditingController(
      text: set.weight > 0 ? set.weight.toString() : '',
    );
    _repsController = TextEditingController(
      text: set.reps > 0 ? set.reps.toString() : '',
    );

    _weightController.addListener(_onWeightChanged);
    _repsController.addListener(_onRepsChanged);
  }

  void _onWeightChanged() {
    final newWeight = double.tryParse(_weightController.text) ?? 0.0;
    widget.exercise.sets[widget.setIndex].weight = newWeight;
  }

  void _onRepsChanged() {
    final newReps = int.tryParse(_repsController.text) ?? 0;
    widget.exercise.sets[widget.setIndex].reps = newReps;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final set = widget.exercise.sets[widget.setIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '${widget.setIndex + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Weight Input Box (크고 명확하게)
          Expanded(
            child: _buildLargeInputBox(
              controller: _weightController,
              label: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 12),
          
          // Reps Input Box (크고 명확하게)
          Expanded(
            child: _buildLargeInputBox(
              controller: _repsController,
              label: context.l10n.repsUnit,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 12),
          
          // Completed Checkbox (크게)
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: set.isCompleted,
              onChanged: (value) {
                setState(() {
                  set.isCompleted = value ?? false;
                });
              },
              activeColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Delete Button
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
              size: 24,
            ),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  // 2. 크고 명확한 Input Box (이미지 1 스타일)
  Widget _buildLargeInputBox({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // 라벨 (좌측 상단)
          Positioned(
            left: 12,
            top: 8,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 입력 필드 (중앙 크게)
          Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

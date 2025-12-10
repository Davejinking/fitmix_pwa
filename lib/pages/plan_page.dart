import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../core/error_handler.dart';
import '../widgets/tempo_settings_modal.dart';
import '../services/rhythm_engine.dart';

/// 운동 계획 페이지 - 완전 리팩토링 버전
class PlanPage extends StatefulWidget {
  final DateTime date;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  
  const PlanPage({
    super.key,
    required this.date,
    required this.repo,
    required this.exerciseRepo,
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
  
  // Live Workout Mode
  bool _isWorkoutStarted = false;
  Timer? _workoutTimer;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  int _restSeconds = 0;
  bool _restTimerRunning = false;

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
    if (_currentSession != null) {
      try {
        await widget.repo.put(_currentSession!);
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, '저장되었습니다.');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, '저장 실패: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _saveSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('운동 계획'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Top: Compact Weekly Calendar
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
            onPressed: () {
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
                  onTap: () => _onDateSelected(day),
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
            onPressed: () {
              final nextWeek = _focusedDate.add(const Duration(days: 7));
              _onWeekChanged(nextWeek);
              _onDateSelected(nextWeek);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          child: ExerciseCard(
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
            // 좌측 (40%): 운동 추가 버튼
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
            const SizedBox(width: 12),
            // 우측 (60%): 운동 시작 버튼
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 52, // 고정 높이
                child: ElevatedButton.icon(
                  onPressed: hasExercises ? _startWorkout : null,
                  icon: const Icon(Icons.play_arrow, size: 22),
                  label: const Text(
                    '운동 시작',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
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
        builder: (context) => _ExerciseSelectionPage(
          exerciseRepo: widget.exerciseRepo,
        ),
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

  void _finishWorkout() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    
    // 모든 세트의 체크박스 상태 리셋
    if (_currentSession != null) {
      for (var exercise in _currentSession!.exercises) {
        for (var set in exercise.sets) {
          set.isCompleted = false;
        }
      }
    }
    
    setState(() {
      _isWorkoutStarted = false;
      _restTimerRunning = false;
      _elapsedSeconds = 0;
      _restSeconds = 0;
    });
    _saveSession();
    HapticFeedback.heavyImpact();
    ErrorHandler.showSuccessSnackBar(context, '운동이 완료되었습니다! 🎉');
  }

  void _onSetChecked(bool value) {
    if (value && _isWorkoutStarted) {
      _startRestTimer(90);
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
                        const Text(
                          "REST",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _restTimerRunning ? "$_restSeconds s" : "OFF",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                  child: const Text(
                    "운동 완료",
                    style: TextStyle(
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

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
    this.onSetCompleted,
    this.isWorkoutStarted = false,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final TextEditingController _memoController = TextEditingController();
  bool _isExpanded = true; // Default: Open
  RhythmEngine? _rhythmEngine;
  RhythmMode _currentMode = RhythmMode.tts; // Default

  @override
  void dispose() {
    _memoController.dispose();
    _rhythmEngine?.dispose();
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
        // Title Row (Always Visible)
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.exerciseIndex + 1} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    TextSpan(
                      text: '${widget.exercise.bodyPart} | ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    TextSpan(
                      text: widget.exercise.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dynamic Status Widget (Completion or Progress)
            if (isCompleted)
              // ✅ All Completed: Green Checkmark (Apple-style Reward)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF34C759), // iOS Green
                size: 28,
              )
            else if (!_isExpanded)
              // 📊 In Progress: Blue Badge (Only when collapsed)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedSets / $totalSets SET',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Chevron Icon (Toggle Indicator)
            Icon(
              _isExpanded 
                  ? Icons.keyboard_arrow_up_rounded 
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[500],
              size: 22,
            ),
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
              const Spacer(),
              // Tempo Button
              GestureDetector(
                onTap: () {
                  _showTempoSettings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.exercise.isTempoEnabled
                        ? const Color(0xFF2196F3).withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.exercise.isTempoEnabled
                          ? const Color(0xFF2196F3)
                          : Colors.grey[700]!,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 12,
                        color: widget.exercise.isTempoEnabled
                            ? const Color(0xFF2196F3)
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.exercise.isTempoEnabled
                            ? '${widget.exercise.eccentricSeconds}/${widget.exercise.concentricSeconds}s'
                            : '템포',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.exercise.isTempoEnabled
                              ? const Color(0xFF2196F3)
                              : Colors.grey[400],
                          fontWeight: widget.exercise.isTempoEnabled
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '최근 기록',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
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
              '회',
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
              '완료',
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
        // 템포 시작 버튼 (운동 시작 후 + 템포 활성화 시)
        if (widget.isWorkoutStarted && widget.exercise.isTempoEnabled) ...[
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
        
        // 세트 추가/삭제 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                if (widget.exercise.sets.isNotEmpty) {
                  setState(() {
                    widget.exercise.sets.removeLast();
                  });
                  widget.onUpdate();
                }
              },
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('세트 삭제', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[500],
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
              onPressed: () {
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
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('세트 추가', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
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

    // RhythmEngine 초기화 및 시작
    _rhythmEngine?.dispose();
    _rhythmEngine = RhythmEngine(
      upSeconds: widget.exercise.concentricSeconds,
      downSeconds: widget.exercise.eccentricSeconds,
      targetReps: nextSet.reps,
      mode: _currentMode, // Pass Selected Mode
      onRepComplete: (currentRep) {
        // 진행 상황 표시 (선택사항)
        print('Rep $currentRep completed');
      },
      onSetComplete: () {
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
    );
    
    await _rhythmEngine!.init();
    await _rhythmEngine!.startWorkout();
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

  const _SetRowGrid({
    required this.exercise,
    required this.setIndex,
    required this.onDelete,
    required this.onUpdate,
    this.onSetCompleted,
    this.isWorkoutStarted = false,
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
            ),
          ),
          // Reps Input (3) - Stack Style with Label
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _repsController,
              label: '회',
              keyboardType: TextInputType.number,
            ),
          ),
          // Conditional Action (2)
          Expanded(
            flex: 2,
            child: Center(
              child: Transform.scale(
                scale: 0.85,
                child: Checkbox(
                  value: set.isCompleted,
                  onChanged: widget.isWorkoutStarted
                      ? (value) {
                          final isChecked = value ?? false;
                          setState(() {
                            set.isCompleted = isChecked;
                          });
                          widget.onUpdate();
                          // Rest Timer 트리거
                          if (isChecked && widget.onSetCompleted != null) {
                            widget.onSetCompleted!(isChecked);
                          }
                        }
                      : null, // 운동 시작 전에는 비활성화
                  activeColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
  }) {
    return Container(
      height: 42, // Force Compact: 48 → 42px
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(6), // 8 → 6px
        border: Border.all(
          color: Colors.grey.shade800,
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
                color: Colors.grey.shade500,
              ),
            ),
          ),
          // 2. Centered Input (No Padding)
          Center(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16, // 18 → 16px
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
              label: '회',
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

/// 운동 선택 페이지
class _ExerciseSelectionPage extends StatefulWidget {
  final ExerciseLibraryRepo exerciseRepo;

  const _ExerciseSelectionPage({required this.exerciseRepo});

  @override
  State<_ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<_ExerciseSelectionPage> {
  final List<Exercise> _selectedExercises = [];
  Map<String, List<String>> _library = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      final lib = await widget.exerciseRepo.getLibrary();
      if (mounted) {
        setState(() {
          _library = lib;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleExercise(String name, String bodyPart) {
    setState(() {
      final index = _selectedExercises.indexWhere((e) => e.name == name);
      if (index >= 0) {
        _selectedExercises.removeAt(index);
      } else {
        _selectedExercises.add(Exercise(name: name, bodyPart: bodyPart));
      }
    });
  }

  bool _isSelected(String name) {
    return _selectedExercises.any((e) => e.name == name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('운동 선택'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedExercises.length}개',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in _library.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...entry.value.map((name) {
                    final isSelected = _isSelected(name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF007AFF).withValues(alpha: 0.2)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF007AFF)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : Colors.grey[600],
                        ),
                        onTap: () => _toggleExercise(name, entry.key),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ],
            ),
      bottomNavigationBar: _selectedExercises.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedExercises);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${_selectedExercises.length}개 운동 추가',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

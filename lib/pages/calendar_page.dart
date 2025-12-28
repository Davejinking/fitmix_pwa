import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../widgets/calendar/month_header.dart';
import '../widgets/calendar/week_strip.dart';
import '../core/error_handler.dart';
import 'plan_page.dart';

/// 캘린더 페이지 - PlanPage 기능 통합
class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const CalendarPage({super.key, required this.repo, required this.exerciseRepo});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 상태 관리
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // 데이터
  Session? _currentSession; // Single Source of Truth
  Set<String> _workoutDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _loadWorkoutDates();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final session = await widget.repo.get(widget.repo.ymd(_selectedDay));
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

  void _onDaySelected(DateTime selectedDay) {
    if (mounted) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
      });
      _loadSession();
    }
  }

  Future<void> _saveSession() async {
    if (_currentSession != null) {
      try {
        await widget.repo.put(_currentSession!);
        await _loadWorkoutDates();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, '저장 실패: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _saveSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPlan = _currentSession != null && 
                         _currentSession!.isWorkoutDay && 
                         _currentSession!.exercises.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // 1. 월 헤더
                MonthHeader(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDateSelected: _onDaySelected,
                  repo: widget.repo,
                  exerciseRepo: widget.exerciseRepo,
                ),
                // 2. 주간 스트립
                WeekStrip(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  workoutDates: _workoutDates,
                  onWeekChanged: (newWeekStart) {
                    setState(() {
                      _focusedDay = newWeekStart;
                      _selectedDay = newWeekStart;
                    });
                    _loadSession();
                  },
                ),
                // 3. Dynamic Body (Empty State or Exercise List)
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasPlan
                          ? _buildExerciseList()
                          : _buildEmptyState(),
                ),
              ],
            ),
          ),
        ),
      ),
      // 4. Conditional Bottom Bar
      bottomNavigationBar: _buildBottomBar(hasPlan),
    );
  }

  // Empty State (운동 계획 없음)
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
            '하단의 "운동 계획하기" 버튼을 눌러\n운동을 추가해보세요',
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

  // Exercise List (PlanPage에서 가져온 로직)
  Widget _buildExerciseList() {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _currentSession!.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _currentSession!.exercises[index];
        return ReorderableDragStartListener(
          key: ValueKey(exercise),
          index: index,
          child: Dismissible(
            key: ValueKey('${exercise.name}_$index'), // Unique key for Dismissible
            direction: DismissDirection.endToStart, // Swipe Left to Delete
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            onDismissed: (direction) {
              final deletedExercise = exercise;
              setState(() {
                _currentSession!.exercises.removeAt(index);
              });
              
              // Feedback with Undo option
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${deletedExercise.name} 삭제됨'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: '실행 취소',
                    onPressed: () {
                      setState(() {
                        _currentSession!.exercises.insert(index, deletedExercise);
                      });
                    },
                  ),
                ),
              );
            },
            child: _ExerciseCard(
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
            ),
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

  // Bottom Action Bar (Conditional)
  Widget _buildBottomBar(bool hasPlan) {
    if (!hasPlan) {
      // Case A: Empty State - "운동 계획하기" 버튼
      return Container(
        padding: const EdgeInsets.all(16),
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
          child: ElevatedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add, size: 22),
            label: const Text(
              '운동 계획하기',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // Case B: Has Plan - "운동 추가" + "운동 시작" 버튼
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
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 52,
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
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _startWorkout,
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
            ymd: widget.repo.ymd(_selectedDay),
            exercises: selected,
            isRest: false,
          );
        } else {
          _currentSession!.exercises.addAll(selected);
        }
      });
      await _saveSession();
    }
  }

  Future<void> _startWorkout() async {
    await _saveSession();
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanPage(
            date: _selectedDay,
            repo: widget.repo,
            exerciseRepo: widget.exerciseRepo,
          ),
        ),
      );
      _loadSession();
    }
  }
}

// ExerciseCard와 ExerciseSelectionPage는 plan_page.dart에서 복사
// (간단히 하기 위해 여기서는 placeholder만 작성)


/// 운동 카드 위젯 (Compact Design)
class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  final TextEditingController _memoController = TextEditingController();
  bool _isExpanded = true;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalVolume = widget.exercise.sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );
    
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;
    final bool isCompleted = completedSets > 0 && completedSets == totalSets;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF34C759),
                          size: 28,
                        )
                      else if (!_isExpanded)
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
                      Icon(
                        _isExpanded 
                            ? Icons.keyboard_arrow_up_rounded 
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[500],
                        size: 22,
                      ),
                    ],
                  ),
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
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Container(
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
                ),
                const SizedBox(height: 8),
                Padding(
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
                ),
                const SizedBox(height: 6),
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
                  ),
                ),
                const SizedBox(height: 8),
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
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutQuart,
          ),
        ],
      ),
    );
  }
}

/// Set Row Grid
class _SetRowGrid extends StatefulWidget {
  final Exercise exercise;
  final int setIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _SetRowGrid({
    required this.exercise,
    required this.setIndex,
    required this.onDelete,
    required this.onUpdate,
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
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4452),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.setIndex + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _weightController,
              label: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _repsController,
              label: '회',
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackInput({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 8,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Center(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exercise Selection Page
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

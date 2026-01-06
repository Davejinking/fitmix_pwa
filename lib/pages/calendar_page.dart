import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/exercise_db.dart';
import '../widgets/calendar/month_header.dart';
import '../widgets/calendar/week_strip.dart';
import '../core/error_handler.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_extensions.dart';
import 'active_workout_page.dart';
import 'exercise_selection_page_v2.dart';

/// 캘린더 페이지 - 운동 계획 및 기록 관리
class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const CalendarPage({super.key, required this.repo, required this.exerciseRepo});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  Session? _currentSession;
  Set<String> _workoutDates = {};
  Set<String> _restDates = {};
  bool _isLoading = true;
  
  // 스크롤 컨트롤러 추가
  final ScrollController _scrollController = ScrollController();
  
  // 운동 카드 전체 열기/닫기 상태
  bool _allCardsExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _loadWorkoutDates();
    _loadRestDates();
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

  Future<void> _loadRestDates() async {
    try {
      final allSessions = await widget.repo.listAll();
      if (mounted) {
        setState(() {
          _restDates = allSessions.where((s) => s.isRest).map((s) => s.ymd).toSet();
        });
      }
    } catch (e) {
      // 무시
    }
  }

  Future<void> _saveRestDay() async {
    try {
      await widget.repo.markRest(widget.repo.ymd(_selectedDay), rest: true);
      await _loadRestDates();
      if (mounted) {
        setState(() {});
        ErrorHandler.showSuccessSnackBar(context, context.l10n.restDaySet);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, '휴식 저장 실패: $e');
      }
    }
  }

  Future<void> _cancelRestDay() async {
    try {
      await widget.repo.markRest(widget.repo.ymd(_selectedDay), rest: false);
      await _loadRestDates();
      if (mounted) {
        setState(() {});
        ErrorHandler.showSuccessSnackBar(context, context.l10n.restDayUnset);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, '휴식 해제 실패: $e');
      }
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
        await _loadRestDates();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, '저장 실패: $e');
        }
      }
    }
  }

  // 특정 운동 카드로 스크롤
  void _scrollToExercise(int exerciseIndex) {
    if (!_scrollController.hasClients) return;
    
    // 각 운동 카드의 대략적인 높이 (확장된 상태 기준)
    const double estimatedCardHeight = 300.0;
    const double padding = 8.0;
    
    final double targetOffset = (estimatedCardHeight + padding) * exerciseIndex;
    
    // 부드러운 스크롤 애니메이션
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _saveSession();
    super.dispose();
  }


  // 운동 시작 - 전체 화면 모달로 이동
  Future<void> _startWorkout() async {
    if (_currentSession == null) return;
    
    await _saveSession();
    
    if (mounted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true, // 전체 화면 모달
          builder: (context) => ActiveWorkoutPage(
            session: _currentSession!,
            repo: widget.repo,
            exerciseRepo: widget.exerciseRepo,
            date: _selectedDay,
          ),
        ),
      );
      
      // 운동 완료 후 데이터 새로고침
      if (mounted) {
        await _loadSession();
        await _loadWorkoutDates();
      }
    }
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
                MonthHeader(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDateSelected: _onDaySelected,
                  repo: widget.repo,
                  exerciseRepo: widget.exerciseRepo,
                  workoutDates: _workoutDates,
                  restDates: _restDates,
                  onRestStatusChanged: () async {
                    await _loadRestDates();
                    await _loadSession();
                    if (mounted) setState(() {});
                  },
                ),
                WeekStrip(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: _onDaySelected,
                  workoutDates: _workoutDates,
                  restDates: _restDates,
                  onWeekChanged: (newWeekStart) {
                    setState(() {
                      _focusedDay = newWeekStart;
                      _selectedDay = newWeekStart;
                    });
                    _loadSession();
                  },
                ),
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
      bottomNavigationBar: _buildBottomBar(hasPlan),
    );
  }

  Widget _buildEmptyState() {
    final selectedYmd = widget.repo.ymd(_selectedDay);
    final isRest = _restDates.contains(selectedYmd);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRest ? Icons.event_busy : Icons.fitness_center,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            isRest ? l10n.restingDay : l10n.workoutPlanEmpty,
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            isRest ? l10n.restingDayDesc : l10n.planWorkoutDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    final l10n = AppLocalizations.of(context);
    final exerciseCount = _currentSession!.exercises.length;
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 액션 바 (섹션 헤더 스타일)
        SliverToBoxAdapter(
          child: Padding(
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
          ),
        ),
        // 운동 리스트
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = _currentSession!.exercises[index];
                return Dismissible(
                  key: ValueKey('${exercise.name}_$index'),
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
                      _currentSession!.exercises.removeAt(index);
                    });
                    
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
                    onUpdate: () => setState(() {}),
                    onSetAdded: () => _scrollToExercise(index),
                    forceExpanded: _allCardsExpanded,
                  ),
                );
              },
              childCount: _currentSession!.exercises.length,
            ),
          ),
        ),
      ],
    );
  }
  
  /// 순서 변경 모달
  void _showReorderModal(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReorderExercisesModal(
        exercises: _currentSession!.exercises,
        onReorder: (newOrder) {
          setState(() {
            _currentSession!.exercises.clear();
            _currentSession!.exercises.addAll(newOrder);
          });
        },
      ),
    );
  }


  Widget _buildBottomBar(bool hasPlan) {
    final selectedYmd = widget.repo.ymd(_selectedDay);
    final isRest = _restDates.contains(selectedYmd);
    final l10n = AppLocalizations.of(context);

    if (!hasPlan && !isRest) {
      // Empty State
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, size: 22),
                  label: Text(l10n.planWorkout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _saveRestDay,
                  icon: const Icon(Icons.event_busy, size: 22),
                  label: Text(l10n.markRest, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isRest) {
      // Rest Day
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _cancelRestDay,
            icon: const Icon(Icons.check_circle, size: 22),
            label: Text(l10n.cancelRestDay, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }

    // Has Plan
    final bool isCompleted = _currentSession?.isCompleted ?? false;

    if (isCompleted) {
      // Completed
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentSession!.isCompleted = false;
                });
              },
              icon: const Icon(Icons.edit, size: 20),
              label: Text(l10n.editWorkout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[600]!, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      );
    }

    // Not Completed - "운동 추가" + "운동 시작"
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
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
                  label: Text(l10n.addWorkout, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  label: Text(l10n.startWorkout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}


/// 운동 카드 (계획 모드용 - 간단한 버전)
class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onSetAdded;
  final bool forceExpanded; // 전체 열기/닫기 상태

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
    required this.onSetAdded,
    this.forceExpanded = true,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.forceExpanded;
  }

  @override
  void didUpdateWidget(_ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forceExpanded != widget.forceExpanded) {
      setState(() => _isExpanded = widget.forceExpanded);
    }
  }

  String _getLocalizedBodyPart(String bodyPart, String locale) {
    return ExerciseDB.getBodyPartLocalized(bodyPart, locale);
  }

  String _getLocalizedExerciseName(String name, String locale) {
    return ExerciseDB.getExerciseNameLocalized(name, locale);
  }

  Future<void> _showDeleteExerciseDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final exerciseName = _getLocalizedExerciseName(widget.exercise.name, locale);
    
    // 햅틱 피드백 - 경고성 액션임을 알림
    HapticFeedback.mediumImpact();
    
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                
                // 경고 아이콘 (빨간색)
                Icon(
                  Icons.delete_forever_rounded,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                
                // 제목
                Text(
                  l10n.deleteExerciseTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 설명
                Text(
                  l10n.deleteExerciseMessage(exerciseName),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 버튼들 (세로 배치)
                Column(
                  children: [
                    // 삭제 버튼 (위험한 액션 - 빨간색)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 취소 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (result == true && mounted) {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final totalVolume = widget.exercise.sets.fold<double>(0, (sum, set) => sum + (set.weight * set.reps));
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
              setState(() => _isExpanded = !_isExpanded);
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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                              ),
                              TextSpan(
                                text: '${_getLocalizedBodyPart(widget.exercise.bodyPart, locale)} | ',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                              TextSpan(
                                text: _getLocalizedExerciseName(widget.exercise.name, locale),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 28)
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
                            style: const TextStyle(fontSize: 11, color: Color(0xFF2196F3), fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
                          l10n.totalVolumeShort(totalVolume.toStringAsFixed(0)),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[700]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(l10n.recentRecord, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
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
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(l10n.setLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
                      Expanded(flex: 3, child: Text('kg', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
                      Expanded(flex: 3, child: Text(l10n.repsUnit, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
                      Expanded(flex: 2, child: Text(l10n.completeLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
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
                        setState(() => widget.exercise.sets.removeAt(index));
                        widget.onUpdate();
                      } else {
                        // 마지막 세트 삭제 시 운동 전체 삭제 확인
                        _showDeleteExerciseDialog(context);
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
                          setState(() => widget.exercise.sets.removeLast());
                          widget.onUpdate();
                        }
                      },
                      icon: const Icon(Icons.remove, size: 16),
                      label: Text(l10n.deleteSet, style: const TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey[500]),
                    ),
                    Container(width: 1, height: 20, color: Colors.grey[700], margin: const EdgeInsets.symmetric(horizontal: 8)),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          if (widget.exercise.sets.isNotEmpty) {
                            final lastSet = widget.exercise.sets.last;
                            widget.exercise.sets.add(ExerciseSet(weight: lastSet.weight, reps: lastSet.reps));
                          } else {
                            widget.exercise.sets.add(ExerciseSet());
                          }
                        });
                        widget.onUpdate();
                        
                        // 세트 추가 후 스크롤 (약간의 딜레이 후)
                        Future.delayed(const Duration(milliseconds: 100), () {
                          widget.onSetAdded();
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.addSet, style: const TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2196F3)),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutQuart,
          ),
        ],
      ),
    );
  }
}


/// 세트 Row
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
    _weightController = TextEditingController(text: set.weight > 0 ? set.weight.toString() : '');
    _repsController = TextEditingController(text: set.reps > 0 ? set.reps.toString() : '');
    _weightController.addListener(_onWeightChanged);
    _repsController.addListener(_onRepsChanged);
  }

  void _onWeightChanged() {
    widget.exercise.sets[widget.setIndex].weight = double.tryParse(_weightController.text) ?? 0.0;
    widget.onUpdate();
  }

  void _onRepsChanged() {
    widget.exercise.sets[widget.setIndex].reps = int.tryParse(_repsController.text) ?? 0;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: const Color(0xFF3A4452), borderRadius: BorderRadius.circular(5)),
                alignment: Alignment.center,
                child: Text('${widget.setIndex + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
          Expanded(flex: 3, child: _buildInput(_weightController, 'kg', const TextInputType.numberWithOptions(decimal: true))),
          Expanded(flex: 3, child: _buildInput(_repsController, AppLocalizations.of(context).repsUnit, TextInputType.number)),
          Expanded(
            flex: 2,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, TextInputType keyboardType) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(top: 4, left: 8, child: Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500))),
          Center(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)),
            ),
          ),
        ],
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
    // 화면 높이의 50% (운동 개수에 따라 최대 70%까지)
    final screenHeight = MediaQuery.of(context).size.height;
    final itemCount = _tempExercises.length;
    // 운동 개수에 따라 동적 높이 계산 (최소 40%, 최대 70%)
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
                  const Text(
                    '운동 순서 변경',
                    style: TextStyle(
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
                    child: const Text(
                      '완료',
                      style: TextStyle(
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

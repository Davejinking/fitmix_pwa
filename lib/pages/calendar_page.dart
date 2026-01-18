import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/service_locator.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../data/routine_repo.dart';
import '../data/user_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/exercise_db.dart';
import '../models/routine.dart';
import '../widgets/calendar/week_strip.dart';
import '../widgets/common/iron_app_bar.dart';
import '../core/error_handler.dart';
import '../core/subscription_limits.dart';
import '../l10n/app_localizations.dart';
import '../core/l10n_extensions.dart';
import '../widgets/modals/exercise_detail_modal.dart';
import 'active_workout_page.dart';
import 'exercise_selection_page_v2.dart';
import 'plan_page.dart';

/// 캘린더 페이지 - 운동 계획 및 기록 관리
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late SessionRepo repo;
  late ExerciseLibraryRepo exerciseRepo;
  
  @override
  void initState() {
    super.initState();
    repo = getIt<SessionRepo>();
    exerciseRepo = getIt<ExerciseLibraryRepo>();
    _loadSession();
    _loadWorkoutDates();
    _loadRestDates();
  }
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

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final session = await repo.get(repo.ymd(_selectedDay));
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
      final sessions = await repo.getWorkoutSessions();
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
      final allSessions = await repo.listAll();
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
      await repo.markRest(repo.ymd(_selectedDay), rest: true);
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
      await repo.markRest(repo.ymd(_selectedDay), rest: false);
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
        await repo.put(_currentSession!);
        await _loadWorkoutDates();
        await _loadRestDates();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, '저장 실패: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _saveSession();
    super.dispose();
  }


  Future<void> _startWorkout() async {
    if (_currentSession == null) return;
    
    await _saveSession();
    
    // Check if this is an edit mode (session already completed)
    final isEditing = _currentSession!.isCompleted;
    
    if (mounted) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true, // 전체 화면 모달
          builder: (context) => ActiveWorkoutPage(
            session: _currentSession!,
            repo: repo,
            exerciseRepo: exerciseRepo,
            date: _selectedDay,
            isEditing: isEditing,
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

  // 오늘로 이동
  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDay = today;
      _focusedDay = today;
    });
    _loadSession();
  }

  // 플랜 페이지로 이동
  void _goToPlanPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanPage(
          date: _selectedDay,
          repo: repo,
          exerciseRepo: exerciseRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPlan = _currentSession != null && 
                         _currentSession!.isWorkoutDay && 
                         _currentSession!.exercises.isNotEmpty;
    
    final isToday = _selectedDay.year == DateTime.now().year &&
        _selectedDay.month == DateTime.now().month &&
        _selectedDay.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: Colors.black, // Pure black void
      appBar: IronAppBar(
        actions: [
          // 오늘로 이동 버튼
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: isToday ? Colors.white : Colors.grey[600],
            ),
            onPressed: _goToToday,
            tooltip: 'Today',
          ),
          // 플랜 추가 버튼
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _goToPlanPage,
            tooltip: 'Add Plan',
          ),
          // Spacing to align with body content (16px padding)
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // WeekStrip (Expandable Calendar with built-in header)
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
                // Content Area (Expanded to fill remaining space)
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
    final selectedYmd = repo.ymd(_selectedDay);
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
    final isCompleted = _currentSession!.isCompleted;
    
    // 완료된 운동은 Receipt 스타일로 표시
    if (isCompleted) {
      return _buildReceiptStyleLog();
    }
    
    // 진행 중인 운동은 기존 카드 스타일로 표시
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
                    color: Colors.white, // High-End Monochrome
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showReorderModal(l10n),
                  child: const Icon(
                    Icons.swap_vert,
                    size: 22,
                    color: Colors.white, // High-End Monochrome
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
                    forceExpanded: _allCardsExpanded,
                    sessionRepo: repo, // SessionRepo 전달
                    exerciseRepo: exerciseRepo, // ExerciseLibraryRepo 전달
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
    final selectedYmd = repo.ymd(_selectedDay);
    final isRest = _restDates.contains(selectedYmd);
    final l10n = AppLocalizations.of(context);

    if (!hasPlan && !isRest) {
      // Empty State
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 패딩 줄임
        decoration: BoxDecoration(
          color: Colors.black, // Pure black - seamless
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52, // 56 → 52로 줄임
                child: OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, size: 20), // 22 → 20
                  label: Text(
                    l10n.planWorkout.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15, // 16 → 15
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontFamily: 'Courier', // Monospace tactical
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5), // White ghost style
                    padding: const EdgeInsets.symmetric(vertical: 14), // 16 → 14
                    shape: BeveledRectangleBorder( // Tactical cut
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // 12 → 10
              SizedBox(
                width: double.infinity,
                height: 52, // 56 → 52로 줄임
                child: OutlinedButton.icon(
                  onPressed: _saveRestDay,
                  icon: const Icon(Icons.event_busy, size: 20), // 22 → 20
                  label: Text(
                    l10n.markRest.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15, // 16 → 15
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontFamily: 'Courier', // Monospace tactical
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), // 16 → 14
                    side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                    shape: BeveledRectangleBorder( // Tactical cut
                      borderRadius: BorderRadius.circular(5),
                    ),
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
          color: Colors.black, // Pure black - seamless
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _cancelRestDay,
            icon: const Icon(Icons.check_circle, size: 22),
            label: Text(
              l10n.cancelRestDay.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontFamily: 'Courier', // Monospace tactical
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5), // White ghost style
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: BeveledRectangleBorder( // Tactical cut
                borderRadius: BorderRadius.circular(5),
              ),
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
          color: Colors.black, // Pure black - seamless
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56, // Reduced
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentSession!.isCompleted = false;
                });
              },
              icon: const Icon(Icons.edit, size: 20),
              label: Text(
                l10n.editWorkout.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontFamily: 'Courier', // Monospace tactical
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16), // Reduced
                side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                shape: BeveledRectangleBorder( // Tactical cut
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Not Completed - "운동 추가" + "루틴 저장" + "운동 시작"
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black, // Pure black - seamless
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: 운동 추가 + 루틴 저장
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        l10n.addWorkout.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          fontFamily: 'Courier',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _saveAsRoutine,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: Text(
                        l10n.saveRoutine.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          fontFamily: 'Courier',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: 운동 시작
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startWorkout,
                icon: const Icon(Icons.play_arrow, size: 22),
                label: Text(
                  l10n.startWorkout.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontFamily: 'Courier',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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
            ymd: repo.ymd(_selectedDay),
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

  /// Workout Invoice 스타일 운동 기록 표시 (완료된 운동용)
  /// Retro/Noir Digital Receipt aesthetic
  Widget _buildReceiptStyleLog() {
    final totalSets = _currentSession!.exercises.fold(0, (sum, e) => sum + e.sets.length);
    final duration = totalSets * 3; // Estimate: 3 min per set
    final totalVolume = _currentSession!.totalVolume;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        color: Colors.black, // Pure black background
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Section (Receipt style) - Starts immediately
            _buildInvoiceSummary(duration, totalVolume, totalSets),
            const SizedBox(height: 16),
            _buildDashedDivider(),
            const SizedBox(height: 24), // More breathing space
            
            // Exercise Log Section
            Padding(
              padding: const EdgeInsets.only(top: 8), // Additional top padding
              child: Text(
                'WORKOUT BREAKDOWN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            const SizedBox(height: 16), // More space before exercises
            
            // Exercise List
            ...List.generate(_currentSession!.exercises.length, (index) {
              final exercise = _currentSession!.exercises[index];
              return _buildInvoiceExerciseItem(exercise, index + 1);
            }),
            
            const SizedBox(height: 20),
            _buildDashedDivider(),
            const SizedBox(height: 16),
            
            // Footer
            _buildInvoiceFooter(totalVolume),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary(int duration, double totalVolume, int totalSets) {
    // Compact horizontal layout - single row
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStat('DURATION', '${duration}m'),
          Container(width: 1, height: 16, color: Colors.grey[800]),
          _buildCompactStat('SETS', '$totalSets'),
          Container(width: 1, height: 16, color: Colors.grey[800]),
          _buildCompactStat('VOL', '${(totalVolume / 1000).toStringAsFixed(2)}t', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.0,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight ? Colors.white : Colors.grey[300], // White monochrome for highlight
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceExerciseItem(Exercise exercise, int itemNumber) {
    final maxWeightSet = exercise.sets.isEmpty
        ? null
        : exercise.sets.reduce((a, b) => a.weight > b.weight ? a : b);
    final exerciseVolume = exercise.sets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[900]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // Remove default divider
            ),
            child: ExpansionTile(
              initiallyExpanded: false, // Collapsed by default
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 12, bottom: 16),
              // Pure black/transparent - no grey boxes
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              shape: const Border(), // Remove default borders
          // Header (Collapsed State)
          title: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      // Number - Dimmed, Monospace
                      TextSpan(
                        text: '#${itemNumber.toString().padLeft(2, '0')} ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600], // Dimmed
                          fontFamily: 'Courier', // Monospace
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Name - Bright, Bold
                      TextSpan(
                        text: exercise.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // High contrast
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Summary (Trailing)
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${exercise.sets.length} SETS | ${exerciseVolume.toStringAsFixed(0)}kg',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
          iconColor: Colors.grey[600],
          collapsedIconColor: Colors.grey[600],
          // Body (Expanded State)
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sets breakdown
                ...exercise.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final set = entry.value;
                  final isBest = maxWeightSet != null && set.weight == maxWeightSet.weight;
                  final setVolume = set.weight * set.reps;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4), // Tighter spacing
                    child: Row(
                      children: [
                        // Set number (Flex 1)
                        SizedBox(
                          width: 35,
                          child: Text(
                            '#${(setIndex + 1).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        // Reps x Weight (Flex 3 - closer to index)
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${set.reps.toString().padLeft(2, ' ')} x ${set.weight.toStringAsFixed(1).padLeft(5, ' ')}kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isBest ? const Color(0xFF2962FF) : Colors.grey[400],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        // Volume (Flex 2 - right-aligned but not too far)
                        SizedBox(
                          width: 70,
                          child: Text(
                            '${setVolume.toStringAsFixed(0)}kg',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 8),
                // Exercise subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBTOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                        fontFamily: 'Courier',
                      ),
                    ),
                    Text(
                      '${exerciseVolume.toStringAsFixed(0)}kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
          ),
          // Subtle divider between exercises
          Divider(
            color: Colors.grey[900],
            height: 1,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceFooter(double totalVolume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'TOTAL TONNAGE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            letterSpacing: 1.5,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(totalVolume / 1000).toStringAsFixed(2)} TONS',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2962FF),
            letterSpacing: 1.0,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '- END OF WORKOUT -',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            letterSpacing: 2.0,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        50,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index.isEven ? Colors.grey[800] : Colors.transparent,
          ),
        ),
      ),
    );
  }

  // Save current session as routine
  Future<void> _saveAsRoutine() async {
    if (_currentSession == null || _currentSession!.exercises.isEmpty) {
      ErrorHandler.showErrorSnackBar(context, context.l10n.noExercises);
      return;
    }

    // 🚨 CHECKPOINT: Check routine limit
    final routineRepo = getIt<RoutineRepo>();
    final userRepo = getIt<UserRepo>();
    
    final routines = await routineRepo.listAll();
    final userProfile = await userRepo.getUserProfile();
    final isPro = userProfile?.isPro ?? false;
    
    // Check if user can save more routines
    if (!SubscriptionLimits.canSaveMoreRoutines(
      isPro: isPro,
      currentCount: routines.length,
    )) {
      // 🚫 BLOCKED: Show upgrade dialog
      _showUpgradeDialog();
      return;
    }

    // ✅ ALLOWED: Proceed to save
    String routineName = "";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            context.l10n.saveRoutine.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: context.l10n.enterRoutineName,
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: (val) => routineName = val,
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text(context.l10n.cancel),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                context.l10n.save.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && routineName.isNotEmpty && mounted) {
      try {
        final routine = Routine(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: routineName,
          exercises: _currentSession!.exercises.map((e) => e.copyWith()).toList(),
        );
        await routineRepo.save(routine);
        final sessionRepo = getIt<SessionRepo>();
        final updatedSession = _currentSession!.copyWith(routineName: routineName);
        await sessionRepo.put(updatedSession);
        if (mounted) {
          setState(() {
            _currentSession = updatedSession;
          });
          ErrorHandler.showSuccessSnackBar(context, context.l10n.routineSaved);
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, context.l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  // Show upgrade to PRO dialog
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          context.l10n.routineLimitReached.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          context.l10n.routineLimitMessage(SubscriptionLimits.freeRoutineLimit),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              context.l10n.cancel.toUpperCase(),
              style: TextStyle(color: Colors.grey[400]),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              context.l10n.upgradeToProShort.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Navigate to subscription/upgrade page
              Navigator.pushNamed(context, '/upgrade');
            },
          ),
        ],
      ),
    );
  }
}


/// 운동 카드 (계획 모드용 - 간단한 버전)
class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final bool forceExpanded; // 전체 열기/닫기 상태
  final SessionRepo? sessionRepo; // 최근 기록 조회용
  final ExerciseLibraryRepo? exerciseRepo; // 운동 상세정보용

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
    this.forceExpanded = true,
    this.sessionRepo,
    this.exerciseRepo,
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
    
    final result = await showModalBottomSheet<bool?>(
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

  void _showMemoBottomSheet(BuildContext context) {
    final TextEditingController memoController = TextEditingController(
      text: widget.exercise.memo ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Session Note',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.exercise.name,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memoController,
              maxLength: 200,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'How was this workout?',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.exercise.memo != null && widget.exercise.memo!.isNotEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          widget.exercise.memo = null;
                        });
                        widget.onUpdate();
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[700]!, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (widget.exercise.memo != null && widget.exercise.memo!.isNotEmpty)
                  const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final memo = memoController.text.trim();
                      setState(() {
                        widget.exercise.memo = memo.isEmpty ? null : memo;
                      });
                      widget.onUpdate();
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;
    final bool isCompleted = completedSets > 0 && completedSets == totalSets;

    return Container(
      // NO box decoration - flat log style
      decoration: BoxDecoration(
        color: Colors.transparent, // No background
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.12), // Subtle bottom line only
            width: 1.0,
          ),
        ),
      ),
      // Full width - no horizontal padding
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1️⃣ Index (Simple Grey Text)
                      Text(
                        '#${(widget.exerciseIndex + 1).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // 2️⃣ Exercise Name (Expanded - Text First!)
                      Expanded(
                        child: Text(
                          _getLocalizedExerciseName(widget.exercise.name, locale).toUpperCase(),
                          maxLines: _isExpanded ? null : 1,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // 3️⃣ Dynamic Status Badge (Right aligned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          // IF COMPLETED: Solid White Background (Inverted)
                          // IF ONGOING: Transparent Black Background
                          color: isCompleted ? Colors.white : Colors.transparent,
                          // IF COMPLETED: White Border (matches background)
                          // IF ONGOING: Thin Grey Border
                          border: Border.all(
                            color: isCompleted ? Colors.white : Colors.white24,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4), // Sharp Terminal Look
                        ),
                        child: Text(
                          '$completedSets / $totalSets',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            // IF COMPLETED: Black Text (Inverted)
                            // IF ONGOING: White Text
                            color: isCompleted ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 6),
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
                // Utility Bar (TOP of expanded section)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16), // 2 → 1
                  child: Row(
                    children: [
                      // Left: Target Label (Tech Style - Bracket Format)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '[ ',
                              style: TextStyle(
                                fontSize: 9, // 10 → 9
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontFamily: 'Courier',
                              ),
                            ),
                            TextSpan(
                              text: _getLocalizedBodyPart(widget.exercise.bodyPart, locale).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9, // 10 → 9
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                fontFamily: 'Courier',
                              ),
                            ),
                            TextSpan(
                              text: ' ]',
                              style: TextStyle(
                                fontSize: 9, // 10 → 9
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Right: Info Icon (clickable)
                      GestureDetector(
                        onTap: () {
                          showExerciseDetailModal(
                            context,
                            exerciseName: widget.exercise.name,
                            sessionRepo: widget.sessionRepo,
                            exerciseRepo: widget.exerciseRepo,
                          );
                          HapticFeedback.lightImpact();
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 16, // 18 → 16
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12), // 16 → 12
                      // Right: Memo Icon (clickable)
                      GestureDetector(
                        onTap: () {
                          _showMemoBottomSheet(context);
                          HapticFeedback.lightImpact();
                        },
                        child: Icon(
                          Icons.edit_note,
                          size: 16, // 18 → 16
                          color: (widget.exercise.memo != null && widget.exercise.memo!.isNotEmpty)
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Memo Display Section (if exists)
                if (widget.exercise.memo != null && widget.exercise.memo!.trim().isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _showMemoBottomSheet(context);
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 2, bottom: 2, left: 16, right: 16), // 4 → 2
                      padding: const EdgeInsets.all(6), // 8 → 6
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4), // 6 → 4
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 10, // 12 → 10
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4), // 6 → 4
                          Expanded(
                            child: Text(
                              widget.exercise.memo!,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 11, // 12 → 11
                                height: 1.2, // 1.3 → 1.2
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 1), // Reduced from 2
                
                // Table Grid Header (Column Headers)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0), // Remove bottom padding
                  child: Row(
                    children: [
                      // SET column
                      const SizedBox(
                        width: 30,
                        child: Text(
                          'SET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9, // 10 → 9
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6), // 8 → 6
                      // KG column
                      Expanded(
                        flex: 3,
                        child: Text(
                          'KG',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9, // 10 → 9
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      // REPS column
                      Expanded(
                        flex: 3,
                        child: Text(
                          'REPS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9, // 10 → 9
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      // Action column
                      const SizedBox(width: 40), // 48 → 40
                    ],
                  ),
                ),
                
                // Set list (NO spacing between rows for maximum density)
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
                const SizedBox(height: 1), // Minimal spacing before buttons
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
                      icon: const Icon(Icons.remove, size: 14), // 더 작게 (was 16)
                      label: Text(
                        l10n.deleteSet.toUpperCase(), 
                        style: const TextStyle(
                          fontSize: 10, // 더 작게 (was 11)
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontFamily: 'Courier',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // 더 작게
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Container(
                      width: 1, 
                      height: 12, // 더 짧게 (was 16)
                      color: Colors.grey[800], 
                      margin: const EdgeInsets.symmetric(horizontal: 6), // 더 작게 (was 8)
                    ),
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
                      },
                      icon: const Icon(Icons.add, size: 14), // 더 작게 (was 16)
                      label: Text(
                        l10n.addSet.toUpperCase(), 
                        style: const TextStyle(
                          fontSize: 10, // 더 작게 (was 11)
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontFamily: 'Courier',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // 더 작게
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
    _weightController = TextEditingController(text: set.weight > 0 ? _formatNumber(set.weight) : '');
    _repsController = TextEditingController(text: set.reps > 0 ? set.reps.toString() : '');
    _weightController.addListener(_onWeightChanged);
    _repsController.addListener(_onRepsChanged);
  }

  /// Smart number formatting: Remove unnecessary decimals
  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString(); // 150.0 → 150
    }
    return value.toString(); // 2.5 → 2.5
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
    return SizedBox(
      height: 28.0, // EXTREME COMPACT - 32 → 28
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SET column (30px fixed - matches header)
            SizedBox(
              width: 30,
              child: Center(
                child: Text(
                  '#${widget.setIndex + 1}',
                  style: TextStyle(
                    fontSize: 11, // 12 → 11
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontFamily: 'Courier',
                    height: 1.0,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 6), // 8 → 6
            
            // KG column (Expanded flex: 3 - matches header)
            Expanded(
              flex: 3,
              child: Center(
                child: _buildGridInput(
                  controller: _weightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
            
            // REPS column (Expanded flex: 3 - matches header)
            Expanded(
              flex: 3,
              child: Center(
                child: _buildGridInput(
                  controller: _repsController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            
            // Action column (40px fixed - reduced from 48)
            SizedBox(
              width: 40, // 48 → 40
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 13, // 14 → 13
                  color: Colors.grey[700],
                ),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridInput({
    required TextEditingController controller,
    required TextAlign textAlign,
    required TextInputType keyboardType,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // Rebuild to show focus color
      },
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          final isEmpty = controller.text.isEmpty;
          
          return TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 15, // 16 → 15 for extreme compact
              fontWeight: FontWeight.w900,
              color: hasFocus 
                ? const Color(0xFF2196F3) // Electric Blue when focused
                : (isEmpty ? Colors.grey[800] : Colors.white),
              fontFamily: 'Courier',
              height: 1.0, // TIGHT!
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero, // ZERO PADDING
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                height: 1.0,
              ),
            ),
          );
        },
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
                        color: Colors.white, // White monochrome
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/exercise_db.dart';
import '../../core/error_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../services/tempo_controller.dart';
import '../../data/session_repo.dart';
import '../../data/exercise_library_repo.dart';
import '../../pages/exercise_detail_page.dart';
import '../tempo_settings_modal.dart';
import '../tempo_countdown_modal.dart';

/// 공통 운동 카드 위젯 (CalendarPage, PlanPage 공용)
class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final Function(bool)? onSetCompleted;
  final bool isWorkoutStarted;
  final bool isEditingEnabled;
  final bool? forceExpanded; // null이면 개별 제어, true/false면 강제 적용
  final SessionRepo? sessionRepo; // 최근 기록 조회용
  final ExerciseLibraryRepo? exerciseRepo; // 운동 상세정보용

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdate,
    this.onSetCompleted,
    this.isWorkoutStarted = false,
    this.isEditingEnabled = true,
    this.forceExpanded,
    this.sessionRepo,
    this.exerciseRepo,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final TextEditingController _memoController = TextEditingController();
  bool _isExpanded = true;
  TempoController? _tempoController;
  TempoMode _currentMode = TempoMode.beep;

  @override
  void initState() {
    super.initState();
    // forceExpanded가 설정되어 있으면 초기값으로 사용
    if (widget.forceExpanded != null) {
      _isExpanded = widget.forceExpanded!;
    }
  }

  @override
  void didUpdateWidget(ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // forceExpanded가 변경되면 _isExpanded 동기화
    if (widget.forceExpanded != null && widget.forceExpanded != oldWidget.forceExpanded) {
      setState(() {
        _isExpanded = widget.forceExpanded!;
      });
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    _tempoController?.dispose();
    super.dispose();
  }

  String _getLocalizedBodyPart(String bodyPart, String locale) {
    return ExerciseDB.getBodyPartLocalized(bodyPart, locale);
  }

  String _getLocalizedExerciseName(String name, String locale) {
    return ExerciseDB.getExerciseNameLocalized(name, locale);
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

  void _showExerciseDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(
          exerciseName: widget.exercise.name,
          sessionRepo: widget.sessionRepo,
          exerciseRepo: widget.exerciseRepo,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final totalVolume = widget.exercise.sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );
    
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;
    final bool isCompleted = completedSets > 0 && completedSets == totalSets;

    // 완료된 운동은 Dimmed 처리
    final cardBgColor = isCompleted 
        ? const Color(0xFF1A1D22) 
        : const Color(0xFF252932);
    final textOpacity = isCompleted ? 0.5 : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: isCompleted 
            ? Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            InkWell(
              onTap: () {
                // 개별 토글 항상 가능
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(12),
              child: _buildHeader(locale, totalVolume, completedSets, totalSets, isCompleted, textOpacity, _isExpanded),
            ),
            
            // Body (Collapsible)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildMemoField(l10n),
                  const SizedBox(height: 12),
                  _buildColumnHeaders(l10n),
                  const SizedBox(height: 8),
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
                          ErrorHandler.showInfoSnackBar(context, l10n.minOneSetRequired);
                        }
                      },
                      onUpdate: widget.onUpdate,
                      onSetCompleted: widget.onSetCompleted,
                      isWorkoutStarted: widget.isWorkoutStarted,
                      isEditingEnabled: widget.isEditingEnabled,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFooterActions(l10n),
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
      ),
    );
  }

  Widget _buildHeader(String locale, double totalVolume, int completedSets, int totalSets, bool isCompleted, double textOpacity, bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 타이틀 행
        Row(
          children: [
            // 운동 번호
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.exerciseIndex + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 운동 이름
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedExerciseName(widget.exercise.name, locale),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: textOpacity),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getLocalizedBodyPart(widget.exercise.bodyPart, locale),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500]?.withValues(alpha: textOpacity),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 운동 정보 아이콘
                  GestureDetector(
                    onTap: () => _showExerciseDetail(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 축소 시 세트 진행률 표시
            if (!isExpanded) ...[
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
              const SizedBox(width: 8),
            ],
            // 확장/축소 아이콘
            Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[500],
              size: 24,
            ),
          ],
        ),
        
        // 확장 시 추가 정보
        if (isExpanded) ...[
          const SizedBox(height: 12),
          // 볼륨 + 최근 기록 + 템포 정보
          Row(
            children: [
              // 총 볼륨
              _buildInfoChip(
                icon: Icons.fitness_center,
                label: AppLocalizations.of(context).totalVolumeShort(totalVolume.toStringAsFixed(0)),
                color: Colors.grey[600]!,
              ),
              const Spacer(),
              // 템포 버튼 (완료되지 않은 운동만 표시)
              if (widget.isEditingEnabled && !isCompleted)
                GestureDetector(
                  onTap: _showTempoSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.exercise.isTempoEnabled
                          ? const Color(0xFF2196F3).withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.exercise.isTempoEnabled
                            ? const Color(0xFF2196F3)
                            : Colors.grey[700]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: widget.exercise.isTempoEnabled
                              ? const Color(0xFF2196F3)
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.exercise.isTempoEnabled
                              ? '${widget.exercise.eccentricSeconds}/${widget.exercise.concentricSeconds}s'
                              : 'テンポ',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.exercise.isTempoEnabled
                                ? const Color(0xFF2196F3)
                                : Colors.grey[500],
                            fontWeight: widget.exercise.isTempoEnabled
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
  
  /// 정보 칩 위젯
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }


  Widget _buildMemoField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF323844),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: _memoController,
        enabled: widget.isEditingEnabled,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: l10n.memo,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildColumnHeaders(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              l10n.setLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'kg',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n.repsUnit,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n.completeLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(AppLocalizations l10n) {
    return Column(
      children: [
        // 템포 시작 버튼
        if (widget.isWorkoutStarted && widget.exercise.isTempoEnabled && widget.isEditingEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startTempoSet,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(
                '${l10n.tempoStart} (${widget.exercise.eccentricSeconds}/${widget.exercise.concentricSeconds}s)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              onPressed: widget.isEditingEnabled ? () {
                if (widget.exercise.sets.isNotEmpty) {
                  setState(() {
                    widget.exercise.sets.removeLast();
                  });
                  widget.onUpdate();
                }
              } : null,
              icon: const Icon(Icons.remove, size: 16),
              label: Text(l10n.deleteSet, style: const TextStyle(fontSize: 13)),
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
                    widget.exercise.sets.add(ExerciseSet(weight: lastSet.weight, reps: lastSet.reps));
                  } else {
                    widget.exercise.sets.add(ExerciseSet());
                  }
                });
                widget.onUpdate();
              } : null,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.addSet, style: const TextStyle(fontSize: 13)),
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
    final nextSetIndex = widget.exercise.sets.indexWhere((set) => !set.isCompleted);
    if (nextSetIndex == -1) return;

    final nextSet = widget.exercise.sets[nextSetIndex];
    if (nextSet.reps == 0) {
      ErrorHandler.showInfoSnackBar(context, AppLocalizations.of(context).enterRepsFirst);
      return;
    }

    _tempoController?.dispose();
    _tempoController = TempoController();
    _tempoController!.mode = _currentMode;
    
    await _tempoController!.init();
    
    if (mounted) {
      showTempoCountdownModal(
        context: context,
        controller: _tempoController!,
        totalReps: nextSet.reps,
        downSeconds: widget.exercise.eccentricSeconds,
        upSeconds: widget.exercise.concentricSeconds,
        onComplete: () {
          if (mounted) {
            setState(() {
              nextSet.isCompleted = true;
            });
            widget.onUpdate();
            if (widget.onSetCompleted != null) {
              widget.onSetCompleted!(true);
            }
          }
        },
        onCancel: () {
          _tempoController?.stop();
        },
      );
      
      await _tempoController!.start(
        reps: nextSet.reps,
        downSeconds: widget.exercise.eccentricSeconds,
        upSeconds: widget.exercise.concentricSeconds,
      );
    }
  }
}


/// 세트 Row 위젯
class _SetRowGrid extends StatefulWidget {
  final Exercise exercise;
  final int setIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final Function(bool)? onSetCompleted;
  final bool isWorkoutStarted;
  final bool isEditingEnabled;

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
    final l10n = AppLocalizations.of(context);
    
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      child: Row(
        children: [
          // Set Number
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4452),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.setIndex + 1}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          // Weight Input
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _weightController,
              label: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              isEnabled: widget.isEditingEnabled,
            ),
          ),
          // Reps Input
          Expanded(
            flex: 3,
            child: _buildStackInput(
              controller: _repsController,
              label: l10n.repsUnit,
              keyboardType: TextInputType.number,
              isEnabled: widget.isEditingEnabled,
            ),
          ),
          // Action (Checkbox or Delete)
          Expanded(
            flex: 2,
            child: Center(
              child: widget.isWorkoutStarted
                  ? Transform.scale(
                      scale: 0.75,
                      child: Checkbox(
                        value: set.isCompleted,
                        onChanged: (value) {
                          final isChecked = value ?? false;
                          
                          // 체크 시 kg와 횟수 입력 검증
                          if (isChecked && (set.weight <= 0 || set.reps <= 0)) {
                            HapticFeedback.heavyImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).enterWeightAndReps),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          setState(() {
                            set.isCompleted = isChecked;
                          });
                          widget.onUpdate();
                          if (isChecked && widget.onSetCompleted != null) {
                            widget.onSetCompleted!(isChecked);
                          }
                        },
                        activeColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                    )
                  : IconButton(
                      onPressed: widget.isEditingEnabled ? widget.onDelete : null,
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
    required bool isEnabled,
  }) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isEnabled ? const Color(0xFF2C2C2C) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isEnabled ? Colors.grey.shade800 : Colors.grey.shade900,
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 6,
            child: Text(
              label,
              style: TextStyle(fontSize: 9, color: isEnabled ? Colors.grey.shade500 : Colors.grey.shade700),
            ),
          ),
          Center(
            child: TextFormField(
              controller: controller,
              enabled: isEnabled,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade600,
                height: 1.0,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
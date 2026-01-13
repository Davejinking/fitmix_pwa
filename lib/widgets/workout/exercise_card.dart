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

    return Container(
      // NO box decoration - flat log style (Noir)
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
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
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
                  
                  // 3️⃣ Set Progress Badge (Right aligned)
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.white, size: 24)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey[700]!, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$completedSets / $totalSets',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Body (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Utility Bar (Body Part + Info + Memo)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16),
                  child: Row(
                    children: [
                      // Left: Target Label (Tech Style - Bracket Format)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '[ ',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontFamily: 'Courier',
                              ),
                            ),
                            TextSpan(
                              text: _getLocalizedBodyPart(widget.exercise.bodyPart, locale).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                fontFamily: 'Courier',
                              ),
                            ),
                            TextSpan(
                              text: ' ]',
                              style: TextStyle(
                                fontSize: 9,
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
                        onTap: () => _showExerciseDetail(context),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right: Memo Icon (clickable)
                      GestureDetector(
                        onTap: () {
                          _showMemoBottomSheet(context);
                          HapticFeedback.lightImpact();
                        },
                        child: Icon(
                          Icons.edit_note,
                          size: 16,
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
                      margin: const EdgeInsets.only(top: 2, bottom: 2, left: 16, right: 16),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 10,
                            color: const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.exercise.memo!,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 11,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 1),
                
                // Table Grid Header (Column Headers)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // SET column (flex: 2)
                      Expanded(
                        flex: 2,
                        child: Text(
                          'SET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      // KG column (flex: 4)
                      Expanded(
                        flex: 4,
                        child: Text(
                          'KG',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      // REPS column (flex: 4)
                      Expanded(
                        flex: 4,
                        child: Text(
                          'REPS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      // DONE column (flex: 2)
                      Expanded(
                        flex: 2,
                        child: Text(
                          'DONE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
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
                const SizedBox(height: 1),
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

  void _showMemoBottomSheet(BuildContext context) {
    final TextEditingController memoController = TextEditingController(
      text: widget.exercise.memo ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for full view with keyboard
      backgroundColor: const Color(0xFF1A1A1A), // Dark Theme background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid keyboard overlay
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
            
            // Memo Input
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
            
            // Action Buttons
            Row(
              children: [
                // Clear Button (only show if memo exists)
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
                
                // Save Button
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
                      backgroundColor: const Color(0xFF3B82F6), // Brand Color (Electric Blue)
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
            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
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

  /// Smart number formatting: Remove unnecessary decimals
  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString(); // 150.0 → 150
    }
    return value.toString(); // 2.5 → 2.5
  }

  @override
  void initState() {
    super.initState();
    final set = widget.exercise.sets[widget.setIndex];
    _weightController = TextEditingController(
      text: set.weight > 0 ? _formatNumber(set.weight) : '',
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
    final isDimmed = set.isCompleted; // Completed sets are dimmed
    
    return SizedBox(
      height: 28.0, // EXTREME COMPACT
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // SET column (flex: 2 - matches header)
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  '#${widget.setIndex + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDimmed ? Colors.grey[800] : Colors.grey[600],
                    fontFamily: 'Courier',
                    height: 1.0,
                  ),
                ),
              ),
            ),
            
            // KG column (flex: 4 - matches header)
            Expanded(
              flex: 4,
              child: Center(
                child: _buildGridInput(
                  controller: _weightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  isEnabled: widget.isEditingEnabled,
                  isDimmed: isDimmed,
                ),
              ),
            ),
            
            // REPS column (flex: 4 - matches header)
            Expanded(
              flex: 4,
              child: Center(
                child: _buildGridInput(
                  controller: _repsController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  isEnabled: widget.isEditingEnabled,
                  isDimmed: isDimmed,
                ),
              ),
            ),
            
            // DONE column (flex: 2 - matches header) - EXPANDED TOUCH AREA
            Expanded(
              flex: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque, // Entire area is tappable
                onTap: widget.isWorkoutStarted && widget.isEditingEnabled ? () {
                  final isChecked = !set.isCompleted;
                  
                  // 체크 시 kg와 횟수 입력 검증
                  if (isChecked && (set.weight <= 0 || set.reps <= 0)) {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.enterWeightAndReps),
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
                } : null,
                child: Center(
                  child: widget.isWorkoutStarted
                      ? Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            value: set.isCompleted,
                            onChanged: null, // Handled by GestureDetector
                            activeColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                          ),
                        )
                      : IconButton(
                          onPressed: widget.isEditingEnabled ? widget.onDelete : null,
                          icon: Icon(
                            Icons.close,
                            size: 13,
                            color: Colors.grey[700],
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 28),
                        ),
                ),
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
    required bool isEnabled,
    bool isDimmed = false,
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
            enabled: isEnabled,
            keyboardType: keyboardType,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 15, // Compact but readable
              fontWeight: FontWeight.w900,
              color: isDimmed 
                  ? Colors.grey[800] // Dimmed when completed
                  : (hasFocus 
                      ? const Color(0xFF2196F3) // Electric Blue when focused
                      : (isEmpty ? Colors.grey[800] : Colors.white)),
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
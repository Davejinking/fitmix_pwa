import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../models/muscle_group.dart';

/// 🎨 Modern Workout Card - 완전히 새로운 디자인
/// NO PIPES | Vertical Layout | Chip Style
class ModernWorkoutCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final Function(bool)? onSetCompleted;
  final bool isWorkoutStarted;
  final bool isEditingEnabled;

  const ModernWorkoutCard({
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
  State<ModernWorkoutCard> createState() => _ModernWorkoutCardState();
}

class _ModernWorkoutCardState extends State<ModernWorkoutCard> {
  bool _isExpanded = true;

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
                        widget.exercise.memo = null;
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
                      widget.exercise.memo = memo.isEmpty ? null : memo;
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

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;
    final isCompleted = completedSets > 0 && completedSets == totalSets;

    // 🎯 CRITICAL FIX: Convert string to MuscleGroup enum
    final muscleGroup = MuscleGroupParsing.fromString(widget.exercise.bodyPart);
    final avatarColor = muscleGroup?.color ?? Colors.grey;
    final avatarText = muscleGroup?.abbreviation ?? '??';

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      // 🎯 DYNAMIC HEIGHT - Remove fixed height to allow expansion
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF1A1D22) : const Color(0xFF252932),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted 
            ? Border.all(color: const Color(0xFF2196F3).withOpacity(0.3), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1️⃣ Index (Simple Grey Text)
                Text(
                  '${widget.exerciseIndex + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 12),
                
                // 2️⃣ Color-Coded Avatar with Abbreviation
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: avatarColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: avatarColor,
                      fontFamily: 'Courier',
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // 3️⃣ Exercise Name (Dynamic Expansion) 🎯 MAGIC HAPPENS HERE
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    maxLines: _isExpanded ? 2 : 1, // 🔥 Collapsed: 1 line, Expanded: 2 lines MAX
                    overflow: TextOverflow.ellipsis, // 🔥 Always ellipsis if exceeds
                    softWrap: true, // 🔥 Allow wrapping within maxLines
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 4️⃣ Set Info (Grey Pill) - RIGHTMOST ELEMENT
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? const Color(0xFF2196F3).withOpacity(0.2)
                        : const Color(0xFF3A4452),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedSets / $totalSets',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted ? const Color(0xFF2196F3) : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // 5️⃣ Memo Icon Button
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.note_alt_outlined,
                    size: 22,
                    color: (widget.exercise.memo != null && widget.exercise.memo!.isNotEmpty)
                        ? const Color(0xFF3B82F6) // Active Color (Electric Blue)
                        : Colors.grey[700], // Inactive Color
                  ),
                  onPressed: () {
                    _showMemoBottomSheet(context);
                    HapticFeedback.lightImpact();
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

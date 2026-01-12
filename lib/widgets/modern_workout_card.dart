import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

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

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.exercise.sets.where((set) => set.isCompleted).length;
    final totalSets = widget.exercise.sets.length;
    final isCompleted = completedSets > 0 && completedSets == totalSets;

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../../core/burn_fit_style.dart';

class SetTile extends StatefulWidget {
  final String setKey;
  final int setIndex;
  final double weight;
  final int reps;
  final bool isCompleted;
  final bool isLastSet;
  final Function(bool isCompleted) onSetCompleted;

  const SetTile({
    super.key,
    required this.setKey,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.isCompleted,
    required this.isLastSet,
    required this.onSetCompleted,
  });

  @override
  State<SetTile> createState() => _SetTileState();
}

class _SetTileState extends State<SetTile> {
  late bool _isCompleted;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
      if (_isCompleted) {
        _confettiController.play();
        HapticFeedback.mediumImpact();
      }
      // 부모에게 완료 상태 전달
      widget.onSetCompleted(_isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListTile(
          tileColor: _isCompleted ? Theme.of(context).cardColor.withValues(alpha: 0.5) : null,
          leading: InkWell(
            onTap: _toggleCompletion,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCompleted ? const Color(0xFF007AFF) : Colors.grey,
                  width: 2,
                ),
                color: _isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
              ),
              child: _isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Center(
                      child: Text(
                        '${widget.setIndex + 1}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
          title: Text(
            '${widget.weight} kg × ${widget.reps} 회',
            style: TextStyle(
              decoration: _isCompleted ? TextDecoration.lineThrough : null,
              color: _isCompleted ? BurnFitStyle.secondaryGrayText : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: widget.isLastSet
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '마지막',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/tempo_controller.dart';

/// 템포 모드 실행 시 표시되는 카운트다운 모달
class TempoCountdownModal extends StatefulWidget {
  final TempoController controller;
  final int totalReps;
  final int downSeconds;
  final int upSeconds;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const TempoCountdownModal({
    super.key,
    required this.controller,
    required this.totalReps,
    required this.downSeconds,
    required this.upSeconds,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<TempoCountdownModal> createState() => _TempoCountdownModalState();
}

class _TempoCountdownModalState extends State<TempoCountdownModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  int _phaseTimeRemaining = 0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // 상태 변경 리스너
    widget.controller.onStateChange = () {
      if (mounted) {
        setState(() {});
        _updatePhaseTimer();
        _pulseController.forward().then((_) => _pulseController.reverse());
        HapticFeedback.lightImpact();
      }
    };
    
    widget.controller.onComplete = () {
      if (mounted) {
        widget.onComplete?.call();
        Navigator.of(context).pop();
      }
    };
    
    _startPhaseTimer();
  }

  void _startPhaseTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && widget.controller.isRunning) {
        setState(() {
          if (_phaseTimeRemaining > 0) {
            _phaseTimeRemaining -= 100;
          }
        });
      }
    });
  }

  void _updatePhaseTimer() {
    final phase = widget.controller.phase;
    if (phase == 'down') {
      _phaseTimeRemaining = widget.downSeconds * 1000;
    } else if (phase == 'up') {
      _phaseTimeRemaining = widget.upSeconds * 1000;
    } else if (phase == 'countdown') {
      _phaseTimeRemaining = 800;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _getPhaseColor().withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPhaseColor().withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 정보
              _buildHeader(),
              const SizedBox(height: 32),
              
              // 메인 디스플레이
              _buildMainDisplay(),
              const SizedBox(height: 32),
              
              // 진행 바
              _buildProgressBar(),
              const SizedBox(height: 24),
              
              // 취소 버튼
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 현재 반복
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.repeat, color: Color(0xFF2196F3), size: 18),
              const SizedBox(width: 6),
              Text(
                '${widget.controller.currentRep} / ${widget.totalReps}',
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        
        // 템포 정보
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.downSeconds}s ↓ / ${widget.upSeconds}s ↑',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainDisplay() {
    final phase = widget.controller.phase;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              // 페이즈 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getPhaseColor().withValues(alpha: 0.2),
                  border: Border.all(
                    color: _getPhaseColor(),
                    width: 4,
                  ),
                ),
                child: Icon(
                  _getPhaseIcon(),
                  size: 60,
                  color: _getPhaseColor(),
                ),
              ),
              const SizedBox(height: 20),
              
              // 페이즈 텍스트
              Text(
                _getPhaseText(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _getPhaseColor(),
                  letterSpacing: 4,
                ),
              ),
              
              // 남은 시간 (down/up 페이즈일 때만)
              if (phase == 'down' || phase == 'up') ...[
                const SizedBox(height: 8),
                Text(
                  '${(_phaseTimeRemaining / 1000).ceil()}초',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final currentRep = widget.controller.currentRep;
    final progress = currentRep / widget.totalReps;
    
    return Column(
      children: [
        // 진행률 텍스트
        Text(
          '진행률 ${(progress * 100).toInt()}%',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        
        // 진행 바
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return TextButton.icon(
      onPressed: () {
        widget.controller.stop();
        widget.onCancel?.call();
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.stop, color: Colors.redAccent),
      label: const Text(
        '중지',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 16,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Color _getPhaseColor() {
    switch (widget.controller.phase) {
      case 'countdown':
        return Colors.orange;
      case 'down':
        return const Color(0xFFFF5722); // Deep Orange
      case 'up':
        return const Color(0xFF4CAF50); // Green
      case 'complete':
        return const Color(0xFF2196F3); // Blue
      default:
        return Colors.grey;
    }
  }

  IconData _getPhaseIcon() {
    switch (widget.controller.phase) {
      case 'countdown':
        return Icons.timer;
      case 'down':
        return Icons.arrow_downward;
      case 'up':
        return Icons.arrow_upward;
      case 'complete':
        return Icons.check_circle;
      default:
        return Icons.fitness_center;
    }
  }

  String _getPhaseText() {
    switch (widget.controller.phase) {
      case 'countdown':
        return '준비';
      case 'down':
        return 'DOWN';
      case 'up':
        return 'UP';
      case 'complete':
        return '완료!';
      default:
        return '대기';
    }
  }
}

/// 템포 모달을 표시하는 헬퍼 함수
Future<void> showTempoCountdownModal({
  required BuildContext context,
  required TempoController controller,
  required int totalReps,
  required int downSeconds,
  required int upSeconds,
  VoidCallback? onComplete,
  VoidCallback? onCancel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    builder: (context) => TempoCountdownModal(
      controller: controller,
      totalReps: totalReps,
      downSeconds: downSeconds,
      upSeconds: upSeconds,
      onComplete: onComplete,
      onCancel: onCancel,
    ),
  );
}

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class RestTimerPanel extends StatelessWidget {
  final int restSecondsRemaining;
  final int defaultRestDuration;
  final VoidCallback onCancel;
  final Function(int) onAdjustTime;
  final VoidCallback onTimePickerTap;

  const RestTimerPanel({
    super.key,
    required this.restSecondsRemaining,
    required this.defaultRestDuration,
    required this.onCancel,
    required this.onAdjustTime,
    required this.onTimePickerTap,
  });

  String _formatRestTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = restSecondsRemaining / defaultRestDuration;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // 어두운 회색 배경
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이머 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.restTimer,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFAAAAAA), size: 22),
                  onPressed: onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 타이머 디스플레이 + 컨트롤
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -10초 버튼
                TextButton(
                  onPressed: () => onAdjustTime(-10),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    '-10',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 타이머 숫자 (탭하면 직접 입력)
                Expanded(
                  child: GestureDetector(
                    onTap: onTimePickerTap,
                    child: Column(
                      children: [
                        Text(
                          _formatRestTime(restSecondsRemaining),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900, // 아주 굵게
                            color: Colors.white,
                            fontFamily: 'monospace',
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.restTimeRemaining,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // +30초 버튼
                TextButton(
                  onPressed: () => onAdjustTime(30),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    '+30',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 진행 바 (파란색이 차오르는 느낌)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[800], // 어두운 회색 트랙
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)), // 파란색 진행
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/exercise.dart';
import '../../../services/tempo_controller.dart';

/// Tempo Settings Modal
/// 운동별 템포 설정 (Eccentric/Concentric 시간)
class TempoSettingsModal extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onUpdate;
  final Function(TempoMode)? onModeChanged;
  final TempoMode? initialMode;

  const TempoSettingsModal({
    super.key,
    required this.exercise,
    required this.onUpdate,
    this.onModeChanged,
    this.initialMode,
  });

  @override
  State<TempoSettingsModal> createState() => _TempoSettingsModalState();
}

class _TempoSettingsModalState extends State<TempoSettingsModal> {
  late int _eccentricSeconds;
  late int _concentricSeconds;
  late bool _isTempoEnabled;
  late TempoMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _eccentricSeconds = widget.exercise.eccentricSeconds;
    _concentricSeconds = widget.exercise.concentricSeconds;
    _isTempoEnabled = widget.exercise.isTempoEnabled;
    _selectedMode = widget.initialMode ?? TempoMode.beep;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Color(0xFF2196F3),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '템포 트레이닝',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '화면을 보지 않고 오디오 가이드로 템포를 유지하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),

              // Enable Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.headphones,
                      color: Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '템포 모드 활성화',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isTempoEnabled,
                      onChanged: (value) {
                        setState(() => _isTempoEnabled = value);
                      },
                      activeThumbColor: const Color(0xFF2196F3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_isTempoEnabled) ...[
                // Mode Selector
                _buildModeSelector(),
                const SizedBox(height: 24),
              ],

              // Eccentric Time
              _buildTimeControl(
                label: '내리는 시간 (Eccentric)',
                icon: Icons.arrow_downward,
                value: _eccentricSeconds,
                onChanged: (value) {
                  setState(() => _eccentricSeconds = value);
                },
                enabled: _isTempoEnabled,
              ),
              const SizedBox(height: 16),

              // Concentric Time
              _buildTimeControl(
                label: '올리는 시간 (Concentric)',
                icon: Icons.arrow_upward,
                value: _concentricSeconds,
                onChanged: (value) {
                  setState(() => _concentricSeconds = value);
                },
                enabled: _isTempoEnabled,
              ),
              const SizedBox(height: 24),

              // Tempo Preview
              if (_isTempoEnabled)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Color(0xFF2196F3),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1회당 ${_eccentricSeconds + _concentricSeconds}초',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.exercise.eccentricSeconds = _eccentricSeconds;
                    widget.exercise.concentricSeconds = _concentricSeconds;
                    widget.exercise.isTempoEnabled = _isTempoEnabled;
                    widget.onUpdate();
                    widget.onModeChanged?.call(_selectedMode); // Pass mode back
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사운드 모드',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildModeOption('비프', TempoMode.beep),
              Container(width: 1, height: 20, color: Colors.grey[700]),
              _buildModeOption('TTS', TempoMode.tts),
              Container(width: 1, height: 20, color: Colors.grey[700]),
              _buildModeOption('무음', TempoMode.silent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(String label, TempoMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        behavior: HitTestBehavior.translucent,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeControl({
    required String label,
    required IconData icon,
    required int value,
    required ValueChanged<int> onChanged,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: enabled && value > 1
                    ? () => onChanged(value - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.white,
                iconSize: 32,
              ),
              Expanded(
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$value 초',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: enabled && value < 10
                    ? () => onChanged(value + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.white,
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

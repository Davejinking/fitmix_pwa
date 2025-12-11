import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_recorder_service.dart';

class VoiceRecorderPage extends StatefulWidget {
  const VoiceRecorderPage({super.key});

  @override
  State<VoiceRecorderPage> createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> with SingleTickerProviderStateMixin {
  final AudioRecorderService _service = AudioRecorderService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  // List of cues to record
  final List<String> _cues = [
    'COUNTDOWN_3', 'COUNTDOWN_2', 'COUNTDOWN_1', 'GO',
    'UP', 'DOWN',
    '1', '2', '3', '4', '5',
    'REST', 'COMPLETE'
  ];

  // Map to store friendly names for cues
  final Map<String, String> _cueNames = {
    'COUNTDOWN_3': '카운트다운 "3"',
    'COUNTDOWN_2': '카운트다운 "2"',
    'COUNTDOWN_1': '카운트다운 "1"',
    'GO': '시작 "Go!"',
    'UP': '올리기 "Up!"',
    'DOWN': '내리기 "Down!"',
    '1': '횟수 "하나"',
    '2': '횟수 "둘"',
    '3': '횟수 "셋"',
    '4': '횟수 "넷"',
    '5': '횟수 "다섯"',
    'REST': '휴식 "Rest"',
    'COMPLETE': '세트 완료 "Complete"'
  };

  String? _recordingCue;
  Set<String> _existingRecordings = {};

  @override
  void initState() {
    super.initState();
    _service.init();
    _checkExisting();

    // Animation for breathing glow effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    final Set<String> existing = {};
    for (var cue in _cues) {
      if (await _service.hasRecording(cue)) {
        existing.add(cue);
      }
    }
    if (mounted) {
      setState(() {
        _existingRecordings = existing;
      });
    }
  }

  Future<void> _toggleRecording(String cue) async {
    if (_recordingCue == cue) {
      // Stop
      await _service.stopRecording();
      setState(() {
        _recordingCue = null;
      });
      await _checkExisting();
      HapticFeedback.lightImpact();
    } else {
      if (_recordingCue != null) return; // Already recording another

      // Start
      setState(() {
        _recordingCue = cue;
      });
      await _service.startRecording(cue);
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _play(String cue) async {
    if (_recordingCue != null) return;
    await _service.playRecording(cue);
  }

  Future<void> _delete(String cue) async {
    await _service.deleteRecording(cue);
    await _checkExisting();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep Navy
      appBar: AppBar(
        title: const Text('나만의 보이스 녹음'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cues.length,
            itemBuilder: (context, index) {
              final cue = _cues[index];
              final isRecording = _recordingCue == cue;
              final hasRecording = _existingRecordings.contains(cue);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E), // Lighter Navy
                  borderRadius: BorderRadius.circular(16),
                  border: isRecording
                      ? Border.all(color: Colors.redAccent, width: 2)
                      : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                  boxShadow: isRecording
                      ? [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: _animation.value,
                            spreadRadius: 2,
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cueNames[cue] ?? cue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hasRecording)
                            const Row(
                              children: [
                                Icon(Icons.check_circle,
                                     color: Colors.cyanAccent, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  '녹음됨',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '녹음 필요',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Controls
                    Row(
                      children: [
                        // Play Button
                        if (hasRecording && !isRecording)
                          IconButton(
                            icon: const Icon(Icons.play_arrow_rounded),
                            color: Colors.cyanAccent,
                            iconSize: 32,
                            onPressed: () => _play(cue),
                          ),

                        const SizedBox(width: 8),

                        // Record Button
                        GestureDetector(
                          onTap: () => _toggleRecording(cue),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isRecording
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : const Color(0xFF2C2C2C),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isRecording
                                    ? Colors.redAccent
                                    : Colors.white.withOpacity(0.2),
                                width: 2
                              ),
                              boxShadow: isRecording
                                  ? [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.4),
                                        blurRadius: _animation.value,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: isRecording ? Colors.redAccent : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Delete Button
                        if (hasRecording && !isRecording)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.grey[500],
                            iconSize: 24,
                            onPressed: () => _delete(cue),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}

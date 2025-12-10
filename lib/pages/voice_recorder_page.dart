import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_recorder_service.dart';

class VoiceRecorderPage extends StatefulWidget {
  const VoiceRecorderPage({super.key});

  @override
  State<VoiceRecorderPage> createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  final AudioRecorderService _service = AudioRecorderService();

  // List of cues to record
  final List<String> _cues = [
    '3', '2', '1', 'GO',
    'UP', 'DOWN',
    '1', '2', '3', '4', '5',
    'REST', 'COMPLETE'
  ];

  // Map to store friendly names for cues
  final Map<String, String> _cueNames = {
    '3': '카운트다운 "3"',
    '2': '카운트다운 "2"',
    '1': '카운트다운 "1"',
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('나만의 보이스 녹음'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cues.length,
        itemBuilder: (context, index) {
          final cue = _cues[index];
          final isRecording = _recordingCue == cue;
          final hasRecording = _existingRecordings.contains(cue);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: isRecording
                  ? Border.all(color: Colors.redAccent, width: 2)
                  : null,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasRecording)
                        const Text(
                          '녹음됨',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Play Button
                if (hasRecording && !isRecording)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.white,
                    onPressed: () => _play(cue),
                  ),

                // Record Button
                GestureDetector(
                  onTap: () => _toggleRecording(cue),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.redAccent
                          : const Color(0xFF2C2C2C),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Delete Button
                if (hasRecording && !isRecording)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey[600],
                    onPressed: () => _delete(cue),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

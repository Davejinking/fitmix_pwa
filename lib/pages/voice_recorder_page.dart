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

  // State
  String? _selectedCue; // Currently selected item
  bool _isRecording = false; // Is global recording active?
  Set<String> _existingRecordings = {};

  @override
  void initState() {
    super.initState();
    _service.init();
    _checkExisting();

    // Auto-select first item
    if (_cues.isNotEmpty) {
      _selectedCue = _cues.first;
    }
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

  Future<void> _toggleRecording() async {
    final cue = _selectedCue;
    if (cue == null) return;

    if (_isRecording) {
      // Stop
      await _service.stopRecording();
      setState(() {
        _isRecording = false;
      });
      await _checkExisting();
      HapticFeedback.lightImpact();
    } else {
      // Start
      setState(() {
        _isRecording = true;
      });
      await _service.startRecording(cue);
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _play(String cue) async {
    if (_isRecording) return;
    await _service.playRecording(cue);
  }

  Future<void> _delete(String cue) async {
    if (_isRecording) return;
    await _service.deleteRecording(cue);
    await _checkExisting();
    HapticFeedback.mediumImpact();
  }

  void _selectCue(String cue) {
    if (_isRecording) return; // Prevent changing while recording
    setState(() {
      _selectedCue = cue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '나만의 보이스 녹음',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // List Area
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _cues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cue = _cues[index];
                final isSelected = _selectedCue == cue;
                final hasRecording = _existingRecordings.contains(cue);

                // Use Material to ensure ink splash is visible
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectCue(cue),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[100] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            // Status Dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: hasRecording ? const Color(0xFF4CAF50) : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Text
                            Expanded(
                              child: Text(
                                _cueNames[cue] ?? cue,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // Actions (Play/Delete)
                            if (hasRecording) ...[
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline_rounded),
                                color: Colors.black87,
                                onPressed: () => _play(cue),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 12),
                                 IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  color: Colors.grey,
                                  onPressed: () => _delete(cue),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ]
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Control Area
          Container(
            width: double.infinity, // Ensure full width
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected Cue Indicator
                if (_selectedCue != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _isRecording ? '녹음 중: ${_cueNames[_selectedCue!]}' : '선택됨: ${_cueNames[_selectedCue!]}',
                      style: TextStyle(
                        color: _isRecording ? Colors.redAccent : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Main Record Button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.redAccent : Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.redAccent : Colors.black).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

/// High-Precision Rhythm Engine
/// Low-latency audio metronome for tempo training
class RhythmEngine {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _beepPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();
  
  // Settings
  final int upSeconds;
  final int downSeconds;
  final int targetReps;
  
  bool _isPlaying = false;
  
  // Callbacks
  Function(int currentRep)? onRepComplete;
  VoidCallback? onSetComplete;
  
  RhythmEngine({
    required this.upSeconds,
    required this.downSeconds,
    required this.targetReps,
    this.onRepComplete,
    this.onSetComplete,
  });
  
  Future<void> init() async {
    try {
      // 1. Configure TTS for English (Sharp & Fast)
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.7); // Faster
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false); // Non-blocking
      
      // 2. Configure Audio Players for Low Latency
      await _beepPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
      
      print('✅ Rhythm Engine initialized');
    } catch (e) {
      print('❌ Rhythm Engine init error: $e');
    }
  }
  
  void stop() {
    _isPlaying = false;
    _tts.stop();
    _beepPlayer.stop();
    _tickPlayer.stop();
  }
  
  Future<void> startWorkout() async {
    if (_isPlaying) return;
    _isPlaying = true;
    
    try {
      // --- PHASE 1: F1 Start Sequence ---
      await _f1StartSequence();
      
      // --- PHASE 2: Rep Loop ---
      for (int rep = 1; rep <= targetReps; rep++) {
        if (!_isPlaying) break;
        
        // 1. UP Phase
        await _upPhase();
        
        // 2. DOWN Phase
        await _downPhase();
        
        // 3. Announce Rep
        await _announceRep(rep);
        onRepComplete?.call(rep);
        
        // Short pause between reps
        if (rep < targetReps) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      // --- PHASE 3: Completion ---
      if (_isPlaying) {
        await _completion();
        onSetComplete?.call();
      }
    } catch (e) {
      print('❌ Workout error: $e');
    } finally {
      _isPlaying = false;
    }
  }
  
  /// F1 스타일 시작 시퀀스
  Future<void> _f1StartSequence() async {
    // 3개의 짧은 비프
    for (int i = 3; i > 0; i--) {
      if (!_isPlaying) return;
      
      await _tts.speak("$i");
      await _playBeep(isShort: true);
      HapticFeedback.lightImpact();
      
      await Future.delayed(const Duration(milliseconds: 800));
    }
    
    // GO!
    if (!_isPlaying) return;
    await _tts.speak("GO");
    await _playBeep(isShort: false);
    HapticFeedback.heavyImpact();
    
    await Future.delayed(const Duration(milliseconds: 600));
  }
  
  /// UP Phase (Concentric) - With ticking metronome
  Future<void> _upPhase() async {
    if (!_isPlaying) return;
    
    // "UP!" command
    await _tts.speak("UP");
    HapticFeedback.mediumImpact();
    
    // Tick every second
    for (int t = 0; t < upSeconds; t++) {
      if (!_isPlaying) break;
      await Future.delayed(const Duration(seconds: 1));
      _playTick(); // Metronome tick
    }
  }
  
  /// DOWN Phase (Eccentric) - With ticking metronome
  Future<void> _downPhase() async {
    if (!_isPlaying) return;
    
    // "DOWN!" command
    await _tts.speak("DOWN");
    HapticFeedback.lightImpact();
    
    // Tick every second
    for (int t = 0; t < downSeconds; t++) {
      if (!_isPlaying) break;
      await Future.delayed(const Duration(seconds: 1));
      _playTick(); // Metronome tick
    }
  }
  
  /// Rep count announcement
  Future<void> _announceRep(int rep) async {
    if (!_isPlaying) return;
    
    final repText = _getEnglishNumber(rep);
    await _tts.speak(repText);
    await Future.delayed(const Duration(milliseconds: 300));
  }
  
  /// Completion
  Future<void> _completion() async {
    await _tts.speak("SET COMPLETE");
    
    // Triple haptic
    for (int i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
  
  /// 비프 사운드 재생
  Future<void> _playBeep({required bool isShort}) async {
    try {
      // 웹에서는 간단한 햅틱으로 대체
      if (isShort) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.heavyImpact();
      }
      
      // TODO: 실제 오디오 파일이 있으면 재생
      // await _beepPlayer.play(AssetSource(isShort ? 'audio/short_beep.mp3' : 'audio/long_beep.mp3'));
    } catch (e) {
      print('Beep error: $e');
    }
  }
  
  /// 틱 사운드 재생 (메트로놈 클릭)
  void _playTick() {
    try {
      // SystemSound click for metronome tick
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.selectionClick();
    } catch (e) {
      // Fallback to haptic only
      HapticFeedback.selectionClick();
      print('Tick sound error: $e');
    }
  }
  
  /// English number conversion
  String _getEnglishNumber(int number) {
    const numbers = [
      '', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE',
      'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
      'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN',
      'SIXTEEN', 'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY'
    ];
    
    if (number < numbers.length) {
      return numbers[number];
    }
    return number.toString();
  }
  
  void dispose() {
    stop();
    _beepPlayer.dispose();
    _tickPlayer.dispose();
  }
}

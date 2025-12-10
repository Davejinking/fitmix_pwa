import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

/// High-Precision Rhythm Engine
/// Low-latency audio metronome for tempo training
class RhythmEngine {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _beepPlayer = AudioPlayer();
  
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
      // Enforce English for consistency ("Optimization")
      var isGood = await _tts.isLanguageAvailable("en-US");
      if (isGood == true) {
         await _tts.setLanguage("en-US");
      } else {
         // Fallback to English generic if US not available, or just hope for the best
         await _tts.setLanguage("en");
      }

      await _tts.setSpeechRate(0.6); // Slightly slower for clear commands
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false); // Non-blocking for precise timing
      
      // 2. Configure Audio Players for Low Latency
      await _beepPlayer.setPlayerMode(PlayerMode.lowLatency);
      
      print('✅ Rhythm Engine initialized');
    } catch (e) {
      print('❌ Rhythm Engine init error: $e');
    }
  }
  
  void stop() {
    _isPlaying = false;
    _tts.stop();
    _beepPlayer.stop();
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
        
        // 1. UP Phase (Concentric)
        await _upPhase();
        
        // 2. DOWN Phase (Eccentric)
        await _downPhase();
        
        // 3. Announce Rep
        await _announceRep(rep);
        onRepComplete?.call(rep);
        
        // Short pause between reps?
        // Usually immediately into next rep or short breath.
        // User said: "One!" -> Repeat.
        // Let's add a tiny buffer so "One" doesn't overlap with next "Up" too much
        await Future.delayed(const Duration(milliseconds: 500));
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
  
  /// F1 Style Start Sequence
  /// "3... 2... 1... GO!"
  Future<void> _f1StartSequence() async {
    // "Ready?" logic could go here, but "3, 2, 1" is standard.

    // 3, 2, 1
    for (int i = 3; i > 0; i--) {
      if (!_isPlaying) return;
      
      // Speak number
      _tts.speak("$i");
      
      // Beep
      _playBeep(isShort: true);
      HapticFeedback.selectionClick();

      await Future.delayed(const Duration(seconds: 1));
    }
    
    // GO!
    if (!_isPlaying) return;
    _tts.speak("GO");
    _playBeep(isShort: false);
    HapticFeedback.heavyImpact();
    
    // Give a moment for "GO" to be heard before starting movement time
    // But usually "GO" is the start signal.
    // So we don't wait too long.
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// UP Phase (Concentric) - Quiet Focus
  Future<void> _upPhase() async {
    if (!_isPlaying) return;
    
    // "UP!" command marks the START of the 2s phase
    _tts.speak("UP");
    HapticFeedback.mediumImpact();
    
    // Wait for the duration (Silence)
    // awaitSpeakCompletion is false, so this runs concurrently with speech.
    // The duration is from the START of "UP".
    await Future.delayed(Duration(seconds: upSeconds));
  }
  
  /// DOWN Phase (Eccentric) - Quiet Focus
  Future<void> _downPhase() async {
    if (!_isPlaying) return;
    
    // "DOWN!" command marks the START of the 4s phase
    _tts.speak("DOWN");
    HapticFeedback.lightImpact();
    
    // Wait for the duration (Silence)
    await Future.delayed(Duration(seconds: downSeconds));
  }
  
  /// Rep count announcement
  Future<void> _announceRep(int rep) async {
    if (!_isPlaying) return;
    
    final repText = _getEnglishNumber(rep);
    _tts.speak(repText);
    // No need for specific haptic here, maybe light?
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
  
  /// Play Beep Sound
  void _playBeep({required bool isShort}) {
    try {
      // Haptic backup
      if (isShort) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.heavyImpact();
      }
      
      // If we had assets, we would play them here.
      // _beepPlayer.play(...)
    } catch (e) {
      print('Beep error: $e');
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
  }
}

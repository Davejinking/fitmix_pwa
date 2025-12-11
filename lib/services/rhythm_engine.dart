import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_recorder_service.dart';

enum RhythmMode {
  tts,    // English TTS (Current)
  sfx,    // Sound Effects (Ding/Chime)
  voice,  // Recorded Voice
  beep,   // Tactile + Simple Beeps
}

/// High-Precision Rhythm Engine
class RhythmEngine {
  final FlutterTts _tts;
  final AudioPlayer _sfxPlayer;
  final AudioRecorderService _recorderService;
  
  // Settings
  final int upSeconds;
  final int downSeconds;
  final int targetReps;
  final RhythmMode mode; // Selected Mode
  
  bool _isPlaying = false;
  
  // Callbacks
  Function(int currentRep)? onRepComplete;
  VoidCallback? onSetComplete;
  
  RhythmEngine({
    required this.upSeconds,
    required this.downSeconds,
    required this.targetReps,
    this.mode = RhythmMode.tts,
    this.onRepComplete,
    this.onSetComplete,
    FlutterTts? tts,
    AudioPlayer? sfxPlayer,
    AudioRecorderService? recorderService,
  }) : _tts = tts ?? FlutterTts(),
       _sfxPlayer = sfxPlayer ?? AudioPlayer(),
       _recorderService = recorderService ?? AudioRecorderService();
  
  Future<void> init() async {
    try {
      // 1. Configure TTS (Even if not used mainly, keep it ready)
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.6);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);

      // 2. Configure SFX Player
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      
      // 3. Init Recorder Service (for playback path resolution)
      if (mode == RhythmMode.voice) {
        await _recorderService.init();
      }
      
      print('✅ Rhythm Engine initialized (Mode: $mode)');
    } catch (e) {
      print('❌ Rhythm Engine init error: $e');
    }
  }
  
  void stop() {
    _isPlaying = false;
    _tts.stop();
    _sfxPlayer.stop();
  }
  
  Future<void> startWorkout() async {
    if (_isPlaying) return;
    _isPlaying = true;
    
    try {
      // --- PHASE 1: Start Sequence ---
      await _startSequence();
      
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
  
  /// Start Sequence: "3, 2, 1, GO"
  Future<void> _startSequence() async {
    for (int i = 3; i > 0; i--) {
      if (!_isPlaying) return;
      
      await _playCue(i.toString()); // "3", "2", "1"
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (!_isPlaying) return;
    await _playCue("GO");
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// UP Phase
  Future<void> _upPhase() async {
    if (!_isPlaying) return;
    
    await _playCue("UP");
    HapticFeedback.mediumImpact();
    await Future.delayed(Duration(seconds: upSeconds));
  }
  
  /// DOWN Phase
  Future<void> _downPhase() async {
    if (!_isPlaying) return;
    
    await _playCue("DOWN");
    HapticFeedback.lightImpact();
    await Future.delayed(Duration(seconds: downSeconds));
  }
  
  /// Rep Announcement
  Future<void> _announceRep(int rep) async {
    if (!_isPlaying) return;
    
    // For Voice Mode, we might not have all numbers recorded.
    // Try to play recorded "1", "2"... if fails, fallback to TTS or SFX?
    // User requested "Chime/Ding" for SFX mode.

    await _playCue(rep.toString(), isRep: true);
  }
  
  /// Completion
  Future<void> _completion() async {
    await _playCue("COMPLETE");
    for (int i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
  
  /// Unified Cue Player
  Future<void> _playCue(String cue, {bool isRep = false}) async {
    try {
      switch (mode) {
        case RhythmMode.tts:
          await _playTTS(cue, isRep);
          break;

        case RhythmMode.voice:
          bool played = false;
          // Try to play recorded file
          if (await _recorderService.hasRecording(cue)) {
             await _recorderService.playRecording(cue);
             played = true;
          } else if (isRep) {
             // Fallback for missing rep numbers: Play simple beep or "Count"?
             // Let's just beep if number is missing
             await _playBeep(isShort: true);
             played = true;
          }

          if (!played) {
            // Fallback to TTS if critical cue (like "UP"/"DOWN") is missing?
            // Or silent. Let's do TTS fallback for safety.
            await _playTTS(cue, isRep);
          }
          break;

        case RhythmMode.sfx:
          await _playSFX(cue, isRep);
          break;

        case RhythmMode.beep:
          await _playBeepCue(cue, isRep);
          break;
      }
    } catch (e) {
      print('PlayCue error: $e');
    }
  }

  // --- Mode Implementations ---

  /// TTS Implementation (Original)
  Future<void> _playTTS(String cue, bool isRep) async {
    if (isRep) {
       // Convert numeric string to int if possible
       int? val = int.tryParse(cue);
       if (val != null) {
         await _tts.speak(_getEnglishNumber(val));
         return;
       }
    }
    await _tts.speak(cue);
  }
  
  /// SFX Implementation (Chime/Ding)
  Future<void> _playSFX(String cue, bool isRep) async {
    // Ideally play different sound assets.
    // Since we don't have assets yet, we'll use SystemSound or Fallback TTS for START/STOP
    // and just Beeps for Counts.

    // START/GO: High Beep
    // UP: Rising Tone (Simulated by high pitch beep)
    // DOWN: Falling Tone (Simulated by low pitch beep)
    // REP: Chime (Simulated by SystemSound.click or similar)

    if (isRep) {
      // Rep completed: Ding!
       // Use SystemSound.play(SystemSoundType.click) or just a nice beep?
       // Let's use TTS "Ding" hack or just silence + Haptic?
       // User wanted "Ding!". Without asset, best is Haptic.
       // Or use TTS to say "Ding"? No.
       // Let's assume user will add assets later.
       // For now, I'll use a placeholder behavior: Heavy Haptic.
       SystemSound.play(SystemSoundType.click);
       return;
    }

    if (cue == "UP") {
      // Rising sound
      SystemSound.play(SystemSoundType.click);
    } else if (cue == "DOWN") {
      // Falling sound
      SystemSound.play(SystemSoundType.click);
    } else if (cue == "GO") {
      SystemSound.play(SystemSoundType.click);
    } else {
      // Countdown numbers
      HapticFeedback.selectionClick();
    }
  }

  /// Beep Implementation (Tactile)
  Future<void> _playBeepCue(String cue, bool isRep) async {
    if (isRep) {
      HapticFeedback.heavyImpact(); // Strong pulse for count
    } else if (cue == "UP") {
      HapticFeedback.mediumImpact();
    } else if (cue == "DOWN") {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    // No sound, just haptics mostly, or minimal system clicks
    if (cue == "GO" || cue == "COMPLETE") {
       SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> _playBeep({required bool isShort}) async {
    HapticFeedback.selectionClick();
  }

  String _getEnglishNumber(int number) {
    const numbers = [
      '', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE',
      'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
      'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN',
      'SIXTEEN', 'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY'
    ];
    if (number < numbers.length) return numbers[number];
    return number.toString();
  }

  void dispose() {
    stop();
    _sfxPlayer.dispose();
    _recorderService.dispose();
  }
}

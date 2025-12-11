import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_recorder_service.dart';
import '../utils/sound_generator.dart';

enum RhythmMode {
  tts,    // English TTS (Current)
  sfx,    // Sound Effects (Ding/Chime)
  voice,  // Recorded Voice
  beep,   // Tactile + Simple Beeps
}

/// High-Precision Rhythm Engine
class RhythmEngine {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioRecorderService _recorderService = AudioRecorderService();

  // Generated Sound Paths
  String? _highBeepPath;
  String? _lowBeepPath;
  String? _dingPath;
  
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
  });
  
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
      
      // 4. Generate Sounds if needed
      if (mode != RhythmMode.tts) {
        _highBeepPath = await SoundGenerator.generateTone(
          filename: 'high_beep.wav',
          frequency: 880, // A5
          duration: 0.15,
        );
        _lowBeepPath = await SoundGenerator.generateTone(
          filename: 'low_beep.wav',
          frequency: 440, // A4
          duration: 0.15,
        );
        _dingPath = await SoundGenerator.generateTone(
          filename: 'ding.wav',
          frequency: 1200, // High Ding
          duration: 0.3,
          volume: 0.7,
        );
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
          }

          if (!played) {
            // Fallback for voice: if recorded cue is missing, use Beeps (not TTS)
            // unless it's a critical word like "UP/DOWN/GO".
            // Actually, playing Beeps is safer than TTS mixing in weirdly.
            await _playSFX(cue, isRep);
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
  
  /// SFX Implementation (Generated WAVs)
  Future<void> _playSFX(String cue, bool isRep) async {
    if (isRep) {
      // Rep completed: Ding!
      if (_dingPath != null) {
        await _sfxPlayer.play(DeviceFileSource(_dingPath!));
      }
      return;
    }

    // Commands
    if (cue == "UP") {
      // High pitch
      if (_highBeepPath != null) await _sfxPlayer.play(DeviceFileSource(_highBeepPath!));
    } else if (cue == "DOWN") {
      // Low pitch
      if (_lowBeepPath != null) await _sfxPlayer.play(DeviceFileSource(_lowBeepPath!));
    } else if (cue == "GO") {
       // High Ding
       if (_dingPath != null) await _sfxPlayer.play(DeviceFileSource(_dingPath!));
    } else {
      // Countdown numbers: Short Beep (Low)
      if (_lowBeepPath != null) await _sfxPlayer.play(DeviceFileSource(_lowBeepPath!));
    }
  }

  /// Beep Implementation (Tactile + Simple Beeps)
  Future<void> _playBeepCue(String cue, bool isRep) async {
    // Play sounds too! (User requested sound)
    await _playSFX(cue, isRep);

    // Add Haptics
    if (isRep) {
      HapticFeedback.heavyImpact();
    } else if (cue == "UP") {
      HapticFeedback.mediumImpact();
    } else if (cue == "DOWN") {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _playBeep({required bool isShort}) async {
    if (isShort) {
       if (_lowBeepPath != null) await _sfxPlayer.play(DeviceFileSource(_lowBeepPath!));
    } else {
       if (_highBeepPath != null) await _sfxPlayer.play(DeviceFileSource(_highBeepPath!));
    }
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

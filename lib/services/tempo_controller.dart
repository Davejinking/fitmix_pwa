import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/sound_generator.dart';

enum TempoMode { tts, beep, silent }

/// 심플한 템포 컨트롤러
class TempoController {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  
  // 사운드 파일 경로 (네이티브 전용)
  String? _highBeepPath;
  String? _lowBeepPath;
  String? _dingPath;
  bool _soundsReady = false;
  
  // 상태
  bool isRunning = false;
  int currentRep = 0;
  String phase = 'idle';
  TempoMode mode = TempoMode.beep; // 기본값: 비프음
  
  int totalPreparationSeconds = 0;
  int currentPreparationSeconds = 0;

  // 콜백
  VoidCallback? onStateChange;
  VoidCallback? onComplete;

  Future<void> init() async {
    // TTS 초기화
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.7);
    await _tts.setVolume(1.0);
    
    // 웹이 아닌 경우에만 비프음 생성
    if (!kIsWeb) {
      try {
        await _player.setPlayerMode(PlayerMode.lowLatency);
        
        _highBeepPath = await SoundGenerator.generateTone(
          filename: 'high_beep.wav',
          frequency: 880,
          duration: 0.15,
          volume: 0.6,
        );
        _lowBeepPath = await SoundGenerator.generateTone(
          filename: 'low_beep.wav',
          frequency: 440,
          duration: 0.15,
          volume: 0.6,
        );
        _dingPath = await SoundGenerator.generateTone(
          filename: 'ding.wav',
          frequency: 1047,
          duration: 0.25,
          volume: 0.7,
        );
        _soundsReady = true;
      } catch (e) {
        _soundsReady = false;
      }
    }
  }

  Future<void> start({
    required int reps,
    required int downSeconds,
    required int upSeconds,
    int preparationSeconds = 0,
  }) async {
    if (isRunning) return;
    isRunning = true;
    currentRep = 0;
    
    // Preparation Phase
    if (preparationSeconds > 0) {
      phase = 'preparation';
      totalPreparationSeconds = preparationSeconds;
      currentPreparationSeconds = preparationSeconds;
      onStateChange?.call();

      for (int i = preparationSeconds; i > 0; i--) {
        if (!isRunning) return;
        currentPreparationSeconds = i;
        onStateChange?.call();
        // 5초 이하일 때만 소리/진동
        if (i <= 5) {
            HapticFeedback.lightImpact();
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // 카운트다운 (3-2-1-GO)
    phase = 'countdown';
    onStateChange?.call();
    
    for (int i = 3; i > 0; i--) {
      if (!isRunning) return;
      await _playCountdown(i);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 800));
    }
    
    await _playGo();
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 300));

    // 반복
    for (int rep = 1; rep <= reps; rep++) {
      if (!isRunning) return;
      currentRep = rep;
      
      // DOWN - 길게 2번 진동 (내려가는 느낌)
      phase = 'down';
      onStateChange?.call();
      await _playDown();
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(seconds: downSeconds - 1));
      
      if (!isRunning) return;
      
      // UP - 짧고 강하게 1번 (올라가는 느낌)
      phase = 'up';
      onStateChange?.call();
      await _playUp();
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(seconds: upSeconds));
      
      if (!isRunning) return;
      
      // 반복 카운트 - 트리플 진동 (완료 신호)
      await _playRepCount(rep);
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // 완료
    phase = 'complete';
    onStateChange?.call();
    await _playDone();
    
    for (int i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }
    
    isRunning = false;
    phase = 'idle';
    onStateChange?.call();
    onComplete?.call();
  }

  // --- 사운드 재생 메서드 ---
  
  Future<void> _playCountdown(int num) async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak("$num");
        break;
      case TempoMode.beep:
        if (_lowBeepPath != null) {
          await _player.play(DeviceFileSource(_lowBeepPath!));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }
  
  Future<void> _playGo() async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak("GO");
        break;
      case TempoMode.beep:
        if (_dingPath != null) {
          await _player.play(DeviceFileSource(_dingPath!));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }
  
  Future<void> _playDown() async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak("DOWN");
        break;
      case TempoMode.beep:
        if (_lowBeepPath != null) {
          await _player.play(DeviceFileSource(_lowBeepPath!));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }
  
  Future<void> _playUp() async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak("UP");
        break;
      case TempoMode.beep:
        if (_highBeepPath != null) {
          await _player.play(DeviceFileSource(_highBeepPath!));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }
  
  Future<void> _playRepCount(int rep) async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak(_numberToWord(rep));
        break;
      case TempoMode.beep:
        if (_dingPath != null) {
          await _player.play(DeviceFileSource(_dingPath!));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }
  
  Future<void> _playDone() async {
    switch (mode) {
      case TempoMode.tts:
        await _tts.speak("DONE");
        break;
      case TempoMode.beep:
        // 3번 딩
        for (int i = 0; i < 3; i++) {
          if (_dingPath != null) {
            await _player.play(DeviceFileSource(_dingPath!));
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
        break;
      case TempoMode.silent:
        break;
    }
  }

  void stop() {
    isRunning = false;
    phase = 'idle';
    _tts.stop();
    _player.stop();
    onStateChange?.call();
  }

  String _numberToWord(int n) {
    const words = ['', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE',
      'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
      'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN'];
    return n < words.length ? words[n] : '$n';
  }

  void dispose() {
    stop();
    _player.dispose();
  }
}

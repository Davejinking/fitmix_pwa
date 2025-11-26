import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

/// Tempo Metronome Service
/// 화면을 보지 않고 템포 트레이닝을 할 수 있도록 오디오 가이드 제공
class TempoMetronomeService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRunning = false;
  Timer? _timer;
  
  TempoMetronomeService() {
    _initTts();
  }
  
  Future<void> _initTts() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }
  
  /// 템포 세트 시작
  /// [reps] 목표 반복 횟수
  /// [eccentricSec] 내리는 시간 (초)
  /// [concentricSec] 올리는 시간 (초)
  Future<void> startTempoSet({
    required int reps,
    required int eccentricSec,
    required int concentricSec,
    Function(int currentRep)? onRepComplete,
    VoidCallback? onSetComplete,
  }) async {
    if (_isRunning) return;
    _isRunning = true;
    
    try {
      // Phase 1: Countdown
      await _countdown();
      
      // Phase 2: Rep Cycle
      for (int rep = 1; rep <= reps; rep++) {
        if (!_isRunning) break;
        
        // Eccentric Phase (Down)
        await _eccentricPhase(eccentricSec);
        
        // Concentric Phase (Up)
        await _concentricPhase(concentricSec);
        
        // Rep Count Announcement
        await _announceRep(rep);
        
        onRepComplete?.call(rep);
        
        // Short pause between reps
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // Phase 3: Completion
      if (_isRunning) {
        await _playCompletionSound();
        await _tts.speak("세트 완료");
        HapticFeedback.heavyImpact();
        onSetComplete?.call();
      }
    } finally {
      _isRunning = false;
    }
  }
  
  /// 카운트다운 (3, 2, 1, 시작)
  Future<void> _countdown() async {
    for (int i = 3; i > 0; i--) {
      await _tts.speak("$i");
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 800));
    }
    await _tts.speak("시작");
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Eccentric Phase (내리는 동작)
  Future<void> _eccentricPhase(int seconds) async {
    for (int i = 0; i < seconds; i++) {
      if (!_isRunning) break;
      await _playLowPitchBeep();
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  
  /// Concentric Phase (올리는 동작)
  Future<void> _concentricPhase(int seconds) async {
    await _playHighPitchBeep();
    HapticFeedback.mediumImpact();
    await Future.delayed(Duration(seconds: seconds));
  }
  
  /// 반복 횟수 음성 안내
  Future<void> _announceRep(int rep) async {
    final repText = _getKoreanNumber(rep);
    await _tts.speak(repText);
  }
  
  /// 낮은 음 비프 (Eccentric)
  Future<void> _playLowPitchBeep() async {
    HapticFeedback.selectionClick();
    // TODO: 실제 오디오 파일 재생
    // await _audioPlayer.play(AssetSource('sounds/low_beep.mp3'));
  }
  
  /// 높은 음 비프 (Concentric)
  Future<void> _playHighPitchBeep() async {
    HapticFeedback.mediumImpact();
    // TODO: 실제 오디오 파일 재생
    // await _audioPlayer.play(AssetSource('sounds/high_beep.mp3'));
  }
  
  /// 완료 사운드
  Future<void> _playCompletionSound() async {
    HapticFeedback.heavyImpact();
    // TODO: 실제 오디오 파일 재생
    // await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
  }
  
  /// 한글 숫자 변환
  String _getKoreanNumber(int number) {
    const koreanNumbers = [
      '', '하나', '둘', '셋', '넷', '다섯',
      '여섯', '일곱', '여덟', '아홉', '열',
      '열하나', '열둘', '열셋', '열넷', '열다섯',
      '열여섯', '열일곱', '열여덟', '열아홉', '스물'
    ];
    
    if (number < koreanNumbers.length) {
      return koreanNumbers[number];
    }
    return number.toString();
  }
  
  /// 템포 중지
  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }
  
  /// 리소스 정리
  void dispose() {
    stop();
    _tts.stop();
    _audioPlayer.dispose();
  }
}

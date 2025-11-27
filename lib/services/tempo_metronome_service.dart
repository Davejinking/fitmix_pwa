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
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.8); // 더 빠르게
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      // 웹 환경 설정
      await _tts.awaitSpeakCompletion(false); // 비동기로 처리
    } catch (e) {
      print('TTS init error: $e');
    }
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
        await _tts.speak("SET COMPLETE");
        HapticFeedback.heavyImpact();
        onSetComplete?.call();
      }
    } finally {
      _isRunning = false;
    }
  }
  
  /// 빠른 카운트다운 (3, 2, 1, GO!)
  Future<void> _countdown() async {
    try {
      // 3, 2, 1 카운트다운
      for (int i = 3; i > 0; i--) {
        await _tts.speak("$i");
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 600)); // 더 빠르게
      }
      // GO!
      await _tts.speak("GO");
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      print('Countdown error: $e');
    }
  }
  
  /// Concentric Phase (올리는 동작) - "UP!"
  Future<void> _concentricPhase(int seconds) async {
    try {
      // "UP!" 커맨드
      await _tts.speak("UP");
      HapticFeedback.mediumImpact();
      
      // 매초 햅틱 피드백
      for (int i = 0; i < seconds; i++) {
        if (!_isRunning) break;
        await Future.delayed(const Duration(seconds: 1));
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      print('Concentric phase error: $e');
    }
  }
  
  /// Eccentric Phase (내리는 동작) - "DOWN!" + 카운트다운
  Future<void> _eccentricPhase(int seconds) async {
    try {
      // "DOWN!" 커맨드
      await _tts.speak("DOWN");
      HapticFeedback.lightImpact();
      
      // 역순 카운트다운: 4, 3, 2, 1
      for (int i = seconds; i > 0; i--) {
        if (!_isRunning) break;
        await Future.delayed(const Duration(milliseconds: 800));
        await _tts.speak("$i");
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      print('Eccentric phase error: $e');
    }
  }
  
  /// 반복 횟수 음성 안내 (영어)
  Future<void> _announceRep(int rep) async {
    final repText = _getEnglishNumber(rep);
    await _tts.speak(repText);
  }
  
  /// 완료 사운드
  Future<void> _playCompletionSound() async {
    try {
      // 3번 햅틱으로 완료 신호
      for (int i = 0; i < 3; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      print('Completion sound error: $e');
    }
  }
  
  /// 영어 숫자 변환
  String _getEnglishNumber(int number) {
    const englishNumbers = [
      '', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE',
      'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
      'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN',
      'SIXTEEN', 'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY'
    ];
    
    if (number < englishNumbers.length) {
      return englishNumbers[number];
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

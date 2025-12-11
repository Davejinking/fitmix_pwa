import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/services/rhythm_engine.dart';
import 'package:fitmix_pwa/services/audio_recorder_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fake_async/fake_async.dart';

// Mocks
class MockFlutterTts extends Mock implements FlutterTts {}
class MockAudioRecorderService extends Mock implements AudioRecorderService {}
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  late RhythmEngine engine;
  late MockFlutterTts mockTts;
  late MockAudioRecorderService mockRecorderService;
  late MockAudioPlayer mockAudioPlayer;

  setUp(() {
    mockTts = MockFlutterTts();
    mockRecorderService = MockAudioRecorderService();
    mockAudioPlayer = MockAudioPlayer();

    // Stubbing basics
    when(() => mockTts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setVolume(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setPitch(any())).thenAnswer((_) async => 1);
    when(() => mockTts.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => mockTts.speak(any())).thenAnswer((_) async => 1);
    when(() => mockTts.stop()).thenAnswer((_) async => 1);

    when(() => mockAudioPlayer.setPlayerMode(any())).thenAnswer((_) async {});
    when(() => mockAudioPlayer.play(any())).thenAnswer((_) async {});
    when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
    when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

    when(() => mockRecorderService.init()).thenAnswer((_) async {});
    when(() => mockRecorderService.dispose()).thenAnswer((_) {});
  });

  test('RhythmEngine plays correct countdown sequence in TTS mode', () {
    fakeAsync((async) {
      engine = RhythmEngine(
        upSeconds: 1,
        downSeconds: 1,
        targetReps: 1,
        mode: RhythmMode.tts,
        tts: mockTts,
        sfxPlayer: mockAudioPlayer,
        recorderService: mockRecorderService,
      );

      engine.init();
      engine.startWorkout();

      // Countdown 3
      async.flushMicrotasks();
      verify(() => mockTts.speak('3')).called(1); // COUNTDOWN_3 -> 3
      async.elapse(const Duration(seconds: 1));

      // Countdown 2
      async.flushMicrotasks();
      verify(() => mockTts.speak('2')).called(1); // COUNTDOWN_2 -> 2
      async.elapse(const Duration(seconds: 1));

      // Countdown 1
      async.flushMicrotasks();
      verify(() => mockTts.speak('1')).called(1); // COUNTDOWN_1 -> 1
      async.elapse(const Duration(seconds: 1));

      // GO
      async.flushMicrotasks();
      verify(() => mockTts.speak('GO')).called(1);
      async.elapse(const Duration(milliseconds: 500));

      // UP
      async.flushMicrotasks();
      verify(() => mockTts.speak('UP')).called(1);
      async.elapse(const Duration(seconds: 1));

      // DOWN
      async.flushMicrotasks();
      verify(() => mockTts.speak('DOWN')).called(1);
      async.elapse(const Duration(seconds: 1));

      // Rep 1
      async.flushMicrotasks();
      verify(() => mockTts.speak('ONE')).called(1); // Rep 1 -> ONE
      async.elapse(const Duration(milliseconds: 500));

      // COMPLETE
      async.flushMicrotasks();
      verify(() => mockTts.speak('COMPLETE')).called(1);

      engine.stop();
    });
  });

  test('RhythmEngine uses correct keys for custom voice', () {
    fakeAsync((async) {
      engine = RhythmEngine(
        upSeconds: 1,
        downSeconds: 1,
        targetReps: 1,
        mode: RhythmMode.voice,
        tts: mockTts,
        sfxPlayer: mockAudioPlayer,
        recorderService: mockRecorderService,
      );

      // Setup recorder service mocks
      when(() => mockRecorderService.hasRecording(any())).thenAnswer((_) async => true);
      when(() => mockRecorderService.playRecording(any())).thenAnswer((_) async {});

      engine.init();
      engine.startWorkout();

      // Countdown 3
      async.flushMicrotasks();
      verify(() => mockRecorderService.playRecording('COUNTDOWN_3')).called(1);
      async.elapse(const Duration(seconds: 1));

      // Countdown 2
      async.flushMicrotasks();
      verify(() => mockRecorderService.playRecording('COUNTDOWN_2')).called(1);
      async.elapse(const Duration(seconds: 1));

      // Countdown 1
      async.flushMicrotasks();
      verify(() => mockRecorderService.playRecording('COUNTDOWN_1')).called(1);
      async.elapse(const Duration(seconds: 1));

      // GO
      async.flushMicrotasks();
      verify(() => mockRecorderService.playRecording('GO')).called(1);

      engine.stop();
    });
  });
}

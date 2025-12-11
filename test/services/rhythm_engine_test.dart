import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fitmix_pwa/services/rhythm_engine.dart';
import 'package:fitmix_pwa/services/audio_recorder_service.dart';

class MockFlutterTts extends Mock implements FlutterTts {}
class MockAudioPlayer extends Mock implements AudioPlayer {}
class MockAudioRecorderService extends Mock implements AudioRecorderService {}

void main() {
  late MockFlutterTts mockTts;
  late MockAudioPlayer mockAudioPlayer;
  late MockAudioRecorderService mockRecorderService;
  late RhythmEngine rhythmEngine;

  setUp(() {
    mockTts = MockFlutterTts();
    mockAudioPlayer = MockAudioPlayer();
    mockRecorderService = MockAudioRecorderService();

    // Stubbing basic methods to prevent errors
    when(() => mockTts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setVolume(any())).thenAnswer((_) async => 1);
    when(() => mockTts.setPitch(any())).thenAnswer((_) async => 1);
    when(() => mockTts.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => mockTts.speak(any())).thenAnswer((_) async => 1);
    when(() => mockTts.stop()).thenAnswer((_) async => 1);

    when(() => mockAudioPlayer.setPlayerMode(any())).thenAnswer((_) async {});
    when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});

    // Stubbing recorder service
    when(() => mockRecorderService.init()).thenAnswer((_) async {});
    when(() => mockRecorderService.dispose()).thenAnswer((_) async {});
  });

  group('RhythmEngine', () {
    test('initializes correctly', () async {
      rhythmEngine = RhythmEngine(
        upSeconds: 1,
        downSeconds: 1,
        targetReps: 5,
        tts: mockTts,
        sfxPlayer: mockAudioPlayer,
        recorderService: mockRecorderService,
      );

      await rhythmEngine.init();

      verify(() => mockTts.setLanguage("en-US")).called(1);
    });

    test('performs full workout sequence correctly in TTS mode', () {
      fakeAsync((async) {
        int repCount = 0;
        bool setComplete = false;

        rhythmEngine = RhythmEngine(
          upSeconds: 1,
          downSeconds: 1,
          targetReps: 2,
          mode: RhythmMode.tts,
          tts: mockTts,
          sfxPlayer: mockAudioPlayer,
          recorderService: mockRecorderService,
          onRepComplete: (rep) {
            repCount = rep;
          },
          onSetComplete: () {
            setComplete = true;
          },
        );

        // Start workout
        rhythmEngine.startWorkout();

        // --- Start Sequence ---
        // 3, 2, 1, GO
        // 1s + 1s + 1s + 0.5s = 3.5s
        async.elapse(const Duration(seconds: 4));
        verify(() => mockTts.speak("3")).called(1);
        verify(() => mockTts.speak("2")).called(1);
        verify(() => mockTts.speak("1")).called(1);
        verify(() => mockTts.speak("GO")).called(1);

        // --- Rep 1 ---
        // UP: 1s
        // DOWN: 1s
        // Announce: 0s (immediate)
        // Delay: 0.5s
        // Total per rep: 2.5s

        async.elapse(const Duration(seconds: 3));

        verify(() => mockTts.speak("UP")).called(1);
        verify(() => mockTts.speak("DOWN")).called(1);
        verify(() => mockTts.speak("ONE")).called(1);
        expect(repCount, equals(1));

        // --- Rep 2 ---
        async.elapse(const Duration(seconds: 3));

        verify(() => mockTts.speak("TWO")).called(1);
        expect(repCount, equals(2));

        // --- Completion ---
        async.elapse(const Duration(seconds: 2));
        verify(() => mockTts.speak("COMPLETE")).called(1);
        expect(setComplete, isTrue);

      });
    });

    test('stops correctly when stop() is called', () {
      fakeAsync((async) {
        rhythmEngine = RhythmEngine(
          upSeconds: 10, // Long duration
          downSeconds: 10,
          targetReps: 5,
          tts: mockTts,
          sfxPlayer: mockAudioPlayer,
          recorderService: mockRecorderService,
        );

        rhythmEngine.startWorkout();
        async.elapse(const Duration(seconds: 1)); // Start sequence

        rhythmEngine.stop();

        async.elapse(const Duration(seconds: 100)); // Fast forward

        verify(() => mockTts.stop()).called(1);
        // Should not have completed many reps
        verifyNever(() => mockTts.speak("FIVE"));
      });
    });
  });
}

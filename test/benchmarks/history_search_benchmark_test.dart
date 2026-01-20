import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';

void main() {
  late HiveSessionRepo repo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_benchmark');
    Hive.init(tempDir.path);

    repo = HiveSessionRepo();
    await repo.init();
    await repo.clearAllData();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Benchmark getRecentExerciseHistory', () async {
    print('Generating 3000 sessions...');
    final sessions = <Session>[];

    for (int i = 0; i < 3000; i++) {
      final ymd = DateTime.now().subtract(Duration(days: i)).toString().substring(0, 10);

      final sessionExercises = <Exercise>[
        Exercise(name: 'Bench Press', bodyPart: 'Chest', sets: [ExerciseSet(weight: 100, reps: 5, isCompleted: true)]),
        Exercise(name: 'Squat', bodyPart: 'Legs', sets: [ExerciseSet(weight: 140, reps: 5, isCompleted: true)]),
      ];

      if (i % 3 == 0) {
        sessionExercises.add(Exercise(name: 'Deadlift', bodyPart: 'Back', sets: [ExerciseSet(weight: 180, reps: 5, isCompleted: true)]));
      }

      sessions.add(Session(ymd: ymd, exercises: sessionExercises, isRest: false, isCompleted: true));
    }

    final stopwatchSetup = Stopwatch()..start();
    for (final s in sessions) {
      await repo.put(s);
    }
    stopwatchSetup.stop();
    print('Setup took ${stopwatchSetup.elapsedMilliseconds}ms');

    // Warm up
    await repo.getRecentExerciseHistory('Bench Press');

    // Benchmark 1: Frequent Exercise (Bench Press - present in all 3000)
    final sw1 = Stopwatch()..start();
    await repo.getRecentExerciseHistory('Bench Press');
    sw1.stop();
    print('Benchmark [Bench Press - 3000 matches]: ${sw1.elapsedMicroseconds}us');

    // Benchmark 2: Medium Frequency (Deadlift - present in 1000)
    final sw2 = Stopwatch()..start();
    await repo.getRecentExerciseHistory('Deadlift');
    sw2.stop();
    print('Benchmark [Deadlift - 1000 matches]: ${sw2.elapsedMicroseconds}us');

    // Benchmark 3: Non-existent
    final sw3 = Stopwatch()..start();
    await repo.getRecentExerciseHistory('NonExistent');
    sw3.stop();
    print('Benchmark [NonExistent]: ${sw3.elapsedMicroseconds}us');
  });
}

import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:intl/intl.dart';

void main() {
  late HiveSessionRepo repo;
  late Directory tmp;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tmp = await Directory.systemTemp.createTemp('fitmix_bench_hist_');
    await Hive.close();
    Hive.init(tmp.path);

    repo = HiveSessionRepo();
    await repo.init();
    await repo.clearAllData();
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    } catch (_) {}
  });

  Future<void> populateData(int count) async {
    final rng = Random(42);
    final exercises = ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Pull Up'];

    final futures = <Future>[];
    for (int i = 0; i < count; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final ymd = DateFormat('yyyy-MM-dd').format(date);

      // Randomly select exercises for this session
      final sessionExercises = <Exercise>[];
      final numExercises = rng.nextInt(3) + 1; // 1 to 3 exercises

      for (int j = 0; j < numExercises; j++) {
        final name = exercises[rng.nextInt(exercises.length)];
        sessionExercises.add(Exercise(
          name: name,
          bodyPart: 'Body',
          sets: [
            ExerciseSet(weight: 100, reps: 5, isCompleted: true),
            ExerciseSet(weight: 100, reps: 5, isCompleted: true),
          ],
        ));
      }

      futures.add(repo.put(Session(
        ymd: ymd,
        exercises: sessionExercises,
        isCompleted: true,
      )));
    }
    await Future.wait(futures);
  }

  test('Benchmark getRecentExerciseHistory performance', () async {
    // Setup: 1000 sessions
    print('Seeding 1000 sessions...');
    await populateData(1000);
    print('Seeding complete.');

    final stopwatch = Stopwatch()..start();

    // Run the operation 100 times to get a stable average
    const iterations = 100;
    for (int i = 0; i < iterations; i++) {
      await repo.getRecentExerciseHistory('Bench Press');
    }

    stopwatch.stop();
    final avgUs = stopwatch.elapsedMicroseconds / iterations;
    print('BENCHMARK_RESULT: Average execution time: ${avgUs.toStringAsFixed(2)} us over $iterations iterations');
  });
}

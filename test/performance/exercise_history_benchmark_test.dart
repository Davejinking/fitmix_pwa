import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'dart:io';

void main() {
  group('HiveSessionRepo Performance', () {
    late Directory tempDir;
    late HiveSessionRepo sessionRepo;

    setUp(() async {
      // Create a temporary directory for Hive
      tempDir = await Directory.systemTemp.createTemp('hive_benchmark_');

      // Initialize Hive with the temp path (no Flutter bindings needed for this logic test)
      Hive.init(tempDir.path);

      // Register Adapters
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExerciseAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExerciseSetAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

      // Initialize Repo
      sessionRepo = HiveSessionRepo();
      await sessionRepo.init();
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Benchmark getRecentExerciseHistory', () async {
      // 1. Seed Data: 1000 sessions
      final now = DateTime.now();
      final sessions = <Session>[];

      print('🌱 Seeding 1000 sessions...');
      for (int i = 0; i < 1000; i++) {
        final date = now.subtract(Duration(days: i));
        final ymd = sessionRepo.ymd(date);

        // Add "Bench Press" every 10 days
        final exercises = <Exercise>[];
        if (i % 10 == 0) {
          exercises.add(Exercise(
            name: 'Bench Press',
            bodyPart: 'Chest',
            sets: [ExerciseSet(weight: 100, reps: 5, isCompleted: true)],
          ));
        }

        // Add "Squat" every 5 days
        if (i % 5 == 0) {
          exercises.add(Exercise(
            name: 'Squat',
            bodyPart: 'Legs',
            sets: [ExerciseSet(weight: 120, reps: 5, isCompleted: true)],
          ));
        }

        // Add "Rare Exercise" only once at the very beginning (oldest)
        if (i == 999) {
          exercises.add(Exercise(
            name: 'Rare Exercise',
            bodyPart: 'Legs',
            sets: [ExerciseSet(weight: 10, reps: 10, isCompleted: true)],
          ));
        }

        // Add random filler data to make session heavier
        exercises.add(Exercise(
           name: 'Filler ${i % 5}',
           bodyPart: 'Arms',
           sets: [ExerciseSet(weight: 10, reps: 10, isCompleted: true)],
        ));

        sessions.add(Session(
          ymd: ymd,
          exercises: exercises,
          isCompleted: true,
        ));
      }

      // Batch insert for setup speed
      final box = Hive.box<Session>(HiveSessionRepo.boxName);
      await box.putAll({for (var s in sessions) s.ymd: s});
      print('✅ Seeding complete.');

      // 2. Benchmark "Bench Press" (Frequent)
      final stopwatch1 = Stopwatch()..start();
      await sessionRepo.getRecentExerciseHistory('Bench Press', limit: 5);
      stopwatch1.stop();
      print('⏱️ Bench Press (Frequent): ${stopwatch1.elapsedMicroseconds} µs');

      // 3. Benchmark "Rare Exercise" (Oldest, requires full scan in worst case)
      final stopwatch2 = Stopwatch()..start();
      await sessionRepo.getRecentExerciseHistory('Rare Exercise', limit: 5);
      stopwatch2.stop();
      print('⏱️ Rare Exercise (Worst Case): ${stopwatch2.elapsedMicroseconds} µs');

      // 4. Benchmark "Non Existent" (Full scan)
      final stopwatch3 = Stopwatch()..start();
      await sessionRepo.getRecentExerciseHistory('Non Existent', limit: 5);
      stopwatch3.stop();
      print('⏱️ Non Existent (Full Scan): ${stopwatch3.elapsedMicroseconds} µs');
    });
  });
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late HiveSessionRepo repo;
  late Directory tempDir;
  late Box<Session> box;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ExerciseSetAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

    repo = HiveSessionRepo();
    await repo.init();
    await repo.clearAllData();
    box = Hive.box<Session>(HiveSessionRepo.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<void> seedSessions(int count) async {
    final sessions = <Session>[];
    for (int i = 0; i < count; i++) {
      final date = DateTime(2020, 1, 1).add(Duration(days: i));
      final ymd = repo.ymd(date);
      sessions.add(Session(ymd: ymd, exercises: [], isRest: false));
    }
    sessions.shuffle();
    // Use put directly to avoid measuring our cache logic during seed if possible,
    // but repo.put is what we want to benchmark later.
    for (var s in sessions) {
      await repo.put(s);
    }
  }

  test('Benchmark: listAll Performance', () async {
    const sessionCount = 5000;
    print('Seeding $sessionCount sessions...');
    await seedSessions(sessionCount);
    print('Done seeding.');

    // Measure listAll
    final stopwatch = Stopwatch()..start();
    final list = await repo.listAll();
    stopwatch.stop();
    print('listAll() time: ${stopwatch.elapsedMicroseconds}us');

    expect(list.length, sessionCount);
    // Verify sort
    for (int i = 0; i < list.length - 1; i++) {
      expect(list[i].ymd.compareTo(list[i+1].ymd) <= 0, true);
    }
  });

  test('Benchmark: put Performance (Single Insert)', () async {
    const sessionCount = 5000;
    await seedSessions(sessionCount);

    final newSession = Session(ymd: '2099-01-01', exercises: [], isRest: false);

    final stopwatch = Stopwatch()..start();
    await repo.put(newSession);
    stopwatch.stop();
    print('put() single time: ${stopwatch.elapsedMicroseconds}us');

    final list = await repo.listAll();
    expect(list.length, sessionCount + 1);
    expect(list.last.ymd, '2099-01-01');
  });

  test('Benchmark: put Performance (Update Existing)', () async {
    const sessionCount = 5000;
    await seedSessions(sessionCount);

    final existingSession = await repo.get('2020-01-01'); // First one
    existingSession!.isRest = true;

    final stopwatch = Stopwatch()..start();
    await repo.put(existingSession);
    stopwatch.stop();
    print('put() update time: ${stopwatch.elapsedMicroseconds}us');
  });
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';

void main() {
  late HiveSessionRepo repo;
  late Directory tmp;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tmp = await Directory.systemTemp.createTemp('fitmix_bench_');
    await Hive.close();
    Hive.init(tmp.path);

    repo = HiveSessionRepo();
    await repo.init();

    if (Hive.isBoxOpen(HiveSessionRepo.boxName)) {
      await Hive.box<Session>(HiveSessionRepo.boxName).clear();
    }
  });

  tearDown(() async {
    if (Hive.isBoxOpen(HiveSessionRepo.boxName)) {
      await Hive.box<Session>(HiveSessionRepo.boxName).close();
      await Hive.deleteBoxFromDisk(HiveSessionRepo.boxName);
    }
    try {
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    } catch (_) {}
  });

  test('Benchmark seedDummyWorkoutData', () async {
    final stopwatch = Stopwatch()..start();
    await repo.seedDummyWorkoutData();
    stopwatch.stop();
    print('BENCHMARK_RESULT: ${stopwatch.elapsedMicroseconds} us');
  });
}

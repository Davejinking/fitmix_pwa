import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fitmix_pwa/models/exercise_library.dart';

void main() {
  late Box<ExerciseLibraryItem> box;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_benchmark');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
       Hive.registerAdapter(ExerciseLibraryItemAdapter());
    }
  });

  tearDown(() async {
    if (box.isOpen) await box.close();
    await tempDir.delete(recursive: true);
  });

  List<ExerciseLibraryItem> generateData(int count) {
    return List.generate(count, (index) {
      final id = 'exercise_$index';
      return ExerciseLibraryItem(
        id: id,
        nameKr: '운동 $index',
        nameEn: 'Exercise $index',
        nameJp: 'Exercise $index',
        targetPart: 'Chest',
        equipmentType: 'Barbell',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });
  }

  test('Benchmark: Sequential Put vs PutAll', () async {
    const dataSize = 5000;
    final data = generateData(dataSize);

    // 1. Sequential Put Benchmark
    box = await Hive.openBox<ExerciseLibraryItem>('sequential_box');
    final stopwatchSeq = Stopwatch()..start();

    for (final item in data) {
      await box.put(item.id, item);
    }

    stopwatchSeq.stop();
    final seqTime = stopwatchSeq.elapsedMilliseconds;
    print('⏱️ Sequential Put ($dataSize items): ${seqTime}ms');

    await box.close();

    // 2. PutAll Benchmark
    box = await Hive.openBox<ExerciseLibraryItem>('batch_box');
    // Generate fresh data to avoid "same instance in two boxes" error
    final batchData = generateData(dataSize);

    final stopwatchBatch = Stopwatch()..start();

    final Map<String, ExerciseLibraryItem> batchMap = {
      for (var item in batchData) item.id: item
    };
    await box.putAll(batchMap);

    stopwatchBatch.stop();
    final batchTime = stopwatchBatch.elapsedMilliseconds;
    print('⏱️ PutAll ($dataSize items): ${batchTime}ms');

    // Result Comparison
    print('📊 Improvement: ${(seqTime / batchTime).toStringAsFixed(2)}x faster');

    expect(batchTime, lessThan(seqTime), reason: 'PutAll should be faster than sequential put');
  });
}

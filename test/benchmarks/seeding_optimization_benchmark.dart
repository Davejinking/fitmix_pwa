import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock class to simulate ExerciseLibraryItem
class MockExercise {
  final String id;
  final String name;
  MockExercise(this.id, this.name);
}

void main() async {
  test('Benchmark Seeding Optimization', () async {
    final tempDir = await Directory.systemTemp.createTemp('hive_benchmark');
    Hive.init(tempDir.path);

    final boxName = 'benchmark_box_${DateTime.now().millisecondsSinceEpoch}';
    final box = await Hive.openBox(boxName);

    // 1. Setup Data
    const existingCount = 10000;
    const newCount = 2000;

    // Populate DB
    final Map<String, String> initialData = {};
    for (int i = 0; i < existingCount; i++) {
      initialData['id_$i'] = 'Exercise $i';
    }
    await box.putAll(initialData);

    // Prepare "JSON" data (10k existing + 2k new)
    final List<MockExercise> jsonExercises = [];
    for (int i = 0; i < existingCount + newCount; i++) {
      jsonExercises.add(MockExercise('id_$i', 'Exercise $i updated'));
    }

    print('Data prepared. Box size: ${box.length}, Incoming size: ${jsonExercises.length}');

    // 2. Measure OLD Approach
    final stopwatchOld = Stopwatch()..start();

    // --- OLD LOGIC START ---
    final existingIds = box.keys.cast<String>().toSet();
    final jsonIds = jsonExercises.map((e) => e.id).toSet();

    int updateCountOld = 0;
    int insertCountOld = 0;

    for (final jsonExercise in jsonExercises) {
      if (existingIds.contains(jsonExercise.id)) {
        updateCountOld++;
      } else {
        insertCountOld++;
      }
    }

    final deletedIds = existingIds.difference(jsonIds);
    for (final deletedId in deletedIds) {
      // log deleted
    }
    // --- OLD LOGIC END ---

    stopwatchOld.stop();
    print('Old Approach Time: ${stopwatchOld.elapsedMilliseconds}ms');

    // Reset Box for fairness (though logic is read-heavy mostly, strict comparison)
    // Actually, we can just run the NEW approach on the same box state since we didn't mutate it in the loop above (we just counted).

    // 3. Measure NEW Approach
    final stopwatchNew = Stopwatch()..start();

    // --- NEW LOGIC START ---
    final jsonIdsNew = jsonExercises.map((e) => e.id).toSet();

    int updateCountNew = 0;
    int insertCountNew = 0;

    for (final jsonExercise in jsonExercises) {
      if (box.containsKey(jsonExercise.id)) { // Changed to containsKey
        updateCountNew++;
      } else {
        insertCountNew++;
      }
    }

    // New Deletion Logic: Iterate keys instead of creating full set
    int deletedCountNew = 0;
    for (final key in box.keys) {
      if (!jsonIdsNew.contains(key)) {
        deletedCountNew++;
      }
    }
    // --- NEW LOGIC END ---

    stopwatchNew.stop();
    print('New Approach Time: ${stopwatchNew.elapsedMilliseconds}ms');

    // Verify logic consistency
    expect(updateCountNew, updateCountOld);
    expect(insertCountNew, insertCountOld);

    print('Improvement: ${stopwatchOld.elapsedMilliseconds - stopwatchNew.elapsedMilliseconds}ms');

    await box.close();
    await tempDir.delete(recursive: true);
  });
}

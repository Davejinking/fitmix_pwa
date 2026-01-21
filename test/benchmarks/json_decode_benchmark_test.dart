import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/models/exercise_library.dart';

void main() {
  test('Benchmark: JSON Decode and Mapping', () {
    // 1. Generate a large JSON string simulating assets/data/initial_exercises.json
    const int itemCount = 10000;
    final List<Map<String, dynamic>> jsonList = List.generate(itemCount, (index) {
      return {
        'id': 'exercise_$index',
        'target_part': 'Chest',
        'equipment_type': 'Barbell',
        'name_kr': '운동 $index',
        'name_en': 'Exercise $index',
        'name_jp': 'Exercise $index',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
    });
    final String jsonString = json.encode(jsonList);

    // 2. Measure time on main thread
    final stopwatch = Stopwatch()..start();

    final List<dynamic> decoded = json.decode(jsonString);
    final List<ExerciseLibraryItem> items = decoded
          .map((json) => ExerciseLibraryItem.fromJson(json as Map<String, dynamic>))
          .toList();

    stopwatch.stop();

    print('⏱️ Main Thread Decoding ($itemCount items): ${stopwatch.elapsedMilliseconds}ms');
    expect(items.length, itemCount);
  });
}

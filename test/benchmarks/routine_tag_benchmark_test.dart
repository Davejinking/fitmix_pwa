
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iron_workout_log/models/routine_tag.dart';

void main() {
  test('Benchmark getColorForLocalizedName', () {
    final stopwatch = Stopwatch()..start();

    // Test data covering all cases
    final testTags = [
      'PUSH', 'プッシュ', '미는 운동',
      'PULL', 'プル', '당기는 운동',
      'LEGS', '脚', '하체',
      'UPPER', '上半身', '상체',
      'LOWER', '下半身', '하체', // Note: '하체' is duplicate in code for LEGS and LOWER
      'FULL BODY', '全身', '전신',
      'CUSTOM TAG 1', 'CUSTOM TAG 2',
    ];

    int iterations = 1000000;

    for (int i = 0; i < iterations; i++) {
      for (final tag in testTags) {
        RoutineTag.getColorForLocalizedName(tag);
      }
    }

    stopwatch.stop();
    print('Execution time for $iterations iterations: ${stopwatch.elapsedMilliseconds}ms');
  });
}

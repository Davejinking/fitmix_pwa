import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/models/muscle_group.dart';
import 'dart:math';

void main() {
  test('Benchmark: MuscleGroup.fromString Performance', () {
    // 1. Setup - Create a large list of test strings
    const int iterations = 100000;
    final random = Random(42); // Fixed seed for reproducibility

    final List<String> testStrings = [];

    // Mix of valid muscle groups strings from different languages and cases
    final validStrings = [
      'Chest', 'chest', 'CHEST', '가슴', '胸',
      'Back', 'back', 'BACK', '등', '背中',
      'Legs', 'legs', 'LEGS', 'Leg', 'leg', '하체', '下半身', '脚', '다리',
      'Shoulders', 'shoulders', 'SHOULDERS', 'Shoulder', 'shoulder', '어깨', '肩',
      'Arms', 'arms', 'ARMS', 'Arm', 'arm', '팔', '腕',
      'Abs', 'abs', 'ABS', 'Core', 'core', 'CORE', '복근', '腹筋', '코어',
      'Cardio', 'cardio', 'CARDIO', '유산소', '有酸素', 'カーディオ',
      'Stretching', 'stretching', 'STRETCHING', 'Stretch', 'stretch', '스트레칭', 'ストレッチ',
      'Full Body', 'full body', 'FULL BODY', 'FullBody', 'fullbody', 'FULLBODY',
      'Full-Body', 'full-body', 'Fullbody', '전신', '全身', '全身運動'
    ];

    // Mix of invalid strings
    final invalidStrings = [
      'Unknown', 'Random', 'Test', '123', '!!!', '', '  ', 'Chest1', ' Back '
    ];

    for (int i = 0; i < iterations; i++) {
      if (random.nextBool()) {
        testStrings.add(validStrings[random.nextInt(validStrings.length)]);
      } else {
        testStrings.add(invalidStrings[random.nextInt(invalidStrings.length)]);
      }
    }

    // 2. Measure Execution Time
    final stopwatch = Stopwatch()..start();

    for (final str in testStrings) {
      MuscleGroupParsing.fromString(str);
    }

    stopwatch.stop();

    print('⏱️ MuscleGroup.fromString ($iterations iterations): ${stopwatch.elapsedMilliseconds}ms');
    print('⏱️ Average per call: ${stopwatch.elapsedMicroseconds / iterations}µs');
  });
}

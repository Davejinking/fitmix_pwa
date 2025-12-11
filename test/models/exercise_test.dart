import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';

void main() {
  group('Exercise Model', () {
    test('supports value equality', () {
      final set1 = ExerciseSet(reps: 10, weight: 20);
      final exercise1 = Exercise(
        name: 'Bench Press',
        bodyPart: 'Chest',
        sets: [set1],
        eccentricSeconds: 3,
        concentricSeconds: 1,
        isTempoEnabled: true,
      );

      final set2 = ExerciseSet(reps: 10, weight: 20);
      final exercise2 = Exercise(
        name: 'Bench Press',
        bodyPart: 'Chest',
        sets: [set2],
        eccentricSeconds: 3,
        concentricSeconds: 1,
        isTempoEnabled: true,
      );

      expect(exercise1, equals(exercise2));
    });

    test('copyWith works correctly', () {
      final exercise = Exercise(
        name: 'Bench Press',
        bodyPart: 'Chest',
        eccentricSeconds: 3,
        concentricSeconds: 1,
        isTempoEnabled: false,
      );

      final updated = exercise.copyWith(
        name: 'Incline Bench Press',
        eccentricSeconds: 4,
        isTempoEnabled: true,
      );

      expect(updated.name, equals('Incline Bench Press'));
      expect(updated.bodyPart, equals('Chest')); // Should remain unchanged
      expect(updated.eccentricSeconds, equals(4));
      expect(updated.concentricSeconds, equals(1)); // Should remain unchanged
      expect(updated.isTempoEnabled, isTrue);
    });

    test('default values are correct', () {
      final exercise = Exercise(
        name: 'Squat',
        bodyPart: 'Legs',
      );

      expect(exercise.eccentricSeconds, equals(4));
      expect(exercise.concentricSeconds, equals(2));
      expect(exercise.isTempoEnabled, isFalse);
      expect(exercise.sets.length, equals(1)); // Should have one default set
    });
  });
}

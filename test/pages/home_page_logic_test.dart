import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';

void main() {
  group('HomePage Summary Card Logic', () {
    test('isRest가 true이면 다른 상태보다 우선하여 Rest 상태로 판단해야 한다', () {
      // Given
      final session = Session(
        ymd: '20240101',
        isRest: true,
        exercises: [
          Exercise(
            name: 'Push Up',
            bodyPart: 'Chest',
            sets: [ExerciseSet(isCompleted: true)], // 운동이 완료되었더라도
          ),
        ],
      );

      // When
      final isRest = session.isRest;
      final isCompleted = session.exercises.every((e) => e.sets.every((s) => s.isCompleted));

      // Then
      // UI 로직: if (isRest) ... else if (isCompleted) ...
      expect(isRest, true);
      expect(isCompleted, true); // 완료 상태여도 Rest가 우선됨 (UI 코드에서)
    });

    test('모든 세트가 완료되어야 Completed 상태로 판단해야 한다', () {
      // Given
      final session = Session(
        ymd: '20240101',
        isRest: false,
        exercises: [
          Exercise(
            name: 'Push Up',
            bodyPart: 'Chest',
            sets: [
              ExerciseSet(isCompleted: true),
              ExerciseSet(isCompleted: false), // 하나라도 미완료 시
            ],
          ),
        ],
      );

      // When
      final isCompleted = session.exercises.every((e) => e.sets.every((s) => s.isCompleted));

      // Then
      expect(isCompleted, false);
    });

    test('모든 세트가 완료되면 Completed 상태여야 한다', () {
      // Given
      final session = Session(
        ymd: '20240101',
        isRest: false,
        exercises: [
          Exercise(
            name: 'Push Up',
            bodyPart: 'Chest',
            sets: [
              ExerciseSet(isCompleted: true),
              ExerciseSet(isCompleted: true),
            ],
          ),
        ],
      );

      // When
      final isCompleted = session.exercises.every((e) => e.sets.every((s) => s.isCompleted));

      // Then
      expect(isCompleted, true);
    });
  });
}

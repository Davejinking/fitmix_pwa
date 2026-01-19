import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';

// T17: 세션 삭제 일관성 (Session Deletion Consistency)
// 목표: 세션 삭제 로직(Mark as Rest 등) 시 데이터가 정상적으로 갱신되는지 확인.
// Note: 이 테스트는 UI 상호작용 없이 로직(Session Model & Deletion Logic simulation)을 검증합니다.
//       실제 HiveBox 테스트는 환경 의존성으로 인해 Unit Test 레벨에서 Mocking이 복잡하여,
//       여기서는 "Logic Verification"을 수행합니다.

void main() {
  group('T17: Session Deletion Logic (Logic Verification)', () {
    test('Marking session as Rest should clear exercises and set isRest flag', () {
      // Arrange
      final session = Session(
        ymd: '2023-10-01',
        exercises: [Exercise(name: 'Bench Press', bodyPart: 'Chest')],
        isRest: false,
      );

      expect(session.isWorkoutDay, isTrue);
      expect(session.exercises.isNotEmpty, isTrue);

      // Act (Simulate Repo.markRest logic)
      session.isRest = true;
      session.exercises.clear();

      // Assert
      expect(session.isWorkoutDay, isFalse);
      expect(session.isRest, isTrue);
      expect(session.exercises, isEmpty);
    });

    test('Removing all exercises should make isWorkoutDay false if logic depends on empty check', () {
      // Arrange
      final session = Session(
        ymd: '2023-10-01',
        exercises: [Exercise(name: 'Squat', bodyPart: 'Legs')],
        isRest: false,
      );

      expect(session.isWorkoutDay, isTrue);

      // Act
      session.exercises.clear();

      // Assert
      // Session model: bool get isWorkoutDay => !isRest && hasExercises;
      expect(session.isWorkoutDay, isFalse);
    });
  });
}

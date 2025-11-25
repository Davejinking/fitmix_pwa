import '../models/session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../data/session_repo.dart';

/// 테스트용 더미 데이터 생성 유틸리티
class DummyDataGenerator {
  final SessionRepo repo;

  DummyDataGenerator(this.repo);

  /// 지난주 월, 수, 금요일에 운동 기록 추가
  Future<void> generateLastWeekWorkouts() async {
    final now = DateTime.now();
    
    // 지난주 월요일 찾기
    final daysToLastMonday = now.weekday + 6; // 이번주 월요일 - 7일
    final lastMonday = now.subtract(Duration(days: daysToLastMonday));
    final lastWednesday = lastMonday.add(const Duration(days: 2));
    final lastFriday = lastMonday.add(const Duration(days: 4));

    // 월요일: 가슴 운동
    await _createChestWorkout(lastMonday);
    
    // 수요일: 등 운동
    await _createBackWorkout(lastWednesday);
    
    // 금요일: 하체 운동
    await _createLegWorkout(lastFriday);
  }

  Future<void> _createChestWorkout(DateTime date) async {
    final ymd = repo.ymd(date);
    
    final session = Session(
      ymd: ymd,
      exercises: [
        Exercise(
          name: '벤치프레스',
          bodyPart: '가슴',
          sets: [
            ExerciseSet(weight: 60, reps: 10),
            ExerciseSet(weight: 70, reps: 8),
            ExerciseSet(weight: 80, reps: 6),
            ExerciseSet(weight: 80, reps: 5),
          ],
        ),
        Exercise(
          name: '인클라인 덤벨프레스',
          bodyPart: '가슴',
          sets: [
            ExerciseSet(weight: 24, reps: 12),
            ExerciseSet(weight: 28, reps: 10),
            ExerciseSet(weight: 28, reps: 8),
          ],
        ),
        Exercise(
          name: '체스트 플라이',
          bodyPart: '가슴',
          sets: [
            ExerciseSet(weight: 15, reps: 15),
            ExerciseSet(weight: 15, reps: 12),
            ExerciseSet(weight: 15, reps: 10),
          ],
        ),
      ],
      isRest: false,
      durationInSeconds: 3600, // 1시간
    );

    await repo.put(session);
  }

  Future<void> _createBackWorkout(DateTime date) async {
    final ymd = repo.ymd(date);
    
    final session = Session(
      ymd: ymd,
      exercises: [
        Exercise(
          name: '데드리프트',
          bodyPart: '등',
          sets: [
            ExerciseSet(weight: 100, reps: 8),
            ExerciseSet(weight: 120, reps: 6),
            ExerciseSet(weight: 140, reps: 5),
            ExerciseSet(weight: 140, reps: 4),
          ],
        ),
        Exercise(
          name: '랫풀다운',
          bodyPart: '등',
          sets: [
            ExerciseSet(weight: 50, reps: 12),
            ExerciseSet(weight: 55, reps: 10),
            ExerciseSet(weight: 60, reps: 8),
          ],
        ),
        Exercise(
          name: '시티드 로우',
          bodyPart: '등',
          sets: [
            ExerciseSet(weight: 45, reps: 12),
            ExerciseSet(weight: 50, reps: 10),
            ExerciseSet(weight: 50, reps: 10),
          ],
        ),
      ],
      isRest: false,
      durationInSeconds: 4200, // 1시간 10분
    );

    await repo.put(session);
  }

  Future<void> _createLegWorkout(DateTime date) async {
    final ymd = repo.ymd(date);
    
    final session = Session(
      ymd: ymd,
      exercises: [
        Exercise(
          name: '스쿼트',
          bodyPart: '하체',
          sets: [
            ExerciseSet(weight: 80, reps: 10),
            ExerciseSet(weight: 100, reps: 8),
            ExerciseSet(weight: 120, reps: 6),
            ExerciseSet(weight: 120, reps: 5),
          ],
        ),
        Exercise(
          name: '레그 프레스',
          bodyPart: '하체',
          sets: [
            ExerciseSet(weight: 150, reps: 12),
            ExerciseSet(weight: 180, reps: 10),
            ExerciseSet(weight: 200, reps: 8),
          ],
        ),
        Exercise(
          name: '레그 컬',
          bodyPart: '하체',
          sets: [
            ExerciseSet(weight: 40, reps: 15),
            ExerciseSet(weight: 45, reps: 12),
            ExerciseSet(weight: 50, reps: 10),
          ],
        ),
      ],
      isRest: false,
      durationInSeconds: 3900, // 1시간 5분
    );

    await repo.put(session);
  }

  /// 모든 더미 데이터 삭제
  Future<void> clearDummyData() async {
    final now = DateTime.now();
    final daysToLastMonday = now.weekday + 6;
    final lastMonday = now.subtract(Duration(days: daysToLastMonday));
    final lastWednesday = lastMonday.add(const Duration(days: 2));
    final lastFriday = lastMonday.add(const Duration(days: 4));

    await repo.delete(repo.ymd(lastMonday));
    await repo.delete(repo.ymd(lastWednesday));
    await repo.delete(repo.ymd(lastFriday));
  }
}

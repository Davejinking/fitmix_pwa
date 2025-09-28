import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';

/// 운동 라이브러리 데이터 저장소 인터페이스
abstract class ExerciseLibraryRepo {
  Future<void> init();
  Future<Map<String, List<String>>> getLibrary();
  Future<void> addExercise(String bodyPart, String exerciseName);
  Future<void> updateExercise(String oldBodyPart, String oldExerciseName, String newBodyPart, String newExerciseName);
  Future<void> deleteExercise(String bodyPart, String exerciseName);
  Future<void> clearAllData();
}

class HiveExerciseLibraryRepo implements ExerciseLibraryRepo {
  static const String boxName = 'exercise_library';
  late Box<List<String>> _box;

  @override
  Future<void> init() async {
    // 앱에선 initFlutter, 테스트에서 이미 Hive.init(...)된 경우 예외 무시
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<List<String>>(boxName);
    } else {
      _box = await Hive.openBox<List<String>>(boxName);
    }

    // 박스가 비어있으면 기본값으로 채움
    if (_box.isEmpty) {
      await _populateWithDefaults();
    }
  }

  Future<void> _populateWithDefaults() async {
    for (final entry in AppConstants.defaultExerciseLibrary.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  @override
  Future<Map<String, List<String>>> getLibrary() async {
    // Hive Box<List<String>>을 Map<String, List<String>>으로 변환
    final map = <String, List<String>>{};
    for (var key in _box.keys) {
      map[key as String] = _box.get(key)!;
    }
    return map;
  }

  @override
  Future<void> addExercise(String bodyPart, String exerciseName) async {
    final exercises = _box.get(bodyPart, defaultValue: [])!;
    if (!exercises.contains(exerciseName)) {
      exercises.add(exerciseName);
      await _box.put(bodyPart, exercises);
    }
  }

  @override
  Future<void> updateExercise(String oldBodyPart, String oldExerciseName, String newBodyPart, String newExerciseName) async {
    // 1. 기존 운동 삭제
    final oldExercises = _box.get(oldBodyPart);
    if (oldExercises != null) {
      oldExercises.remove(oldExerciseName);
      await _box.put(oldBodyPart, oldExercises);
    }

    // 2. 새 운동 추가
    final newExercises = _box.get(newBodyPart, defaultValue: [])!;
    if (!newExercises.contains(newExerciseName)) {
      newExercises.add(newExerciseName);
      await _box.put(newBodyPart, newExercises);
    }
  }

  @override
  Future<void> deleteExercise(String bodyPart, String exerciseName) async {
    final exercises = _box.get(bodyPart);
    if (exercises != null) {
      exercises.remove(exerciseName);
      await _box.put(bodyPart, exercises);
    }
  }

  @override
  Future<void> clearAllData() async => _box.clear();
}
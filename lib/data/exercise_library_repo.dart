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
  late Box _box;

  @override
  Future<void> init() async {
    // 앱에선 initFlutter, 테스트에서 이미 Hive.init(...)된 경우 예외 무시
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box(boxName);
    } else {
      _box = await Hive.openBox(boxName);
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
    final map = <String, List<String>>{};
    for (var key in _box.keys) {
      try {
        final value = _box.get(key);
        if (value != null && value is List) {
          map[key as String] = List<String>.from(value.map((e) => e.toString()));
        }
      } catch (e) {
        // 에러 무시
      }
    }
    return map;
  }

  @override
  Future<void> addExercise(String bodyPart, String exerciseName) async {
    final value = _box.get(bodyPart);
    final exercises = value != null ? List<String>.from(value) : <String>[];
    if (!exercises.contains(exerciseName)) {
      exercises.add(exerciseName);
      await _box.put(bodyPart, exercises);
    }
  }

  @override
  Future<void> updateExercise(String oldBodyPart, String oldExerciseName, String newBodyPart, String newExerciseName) async {
    // 1. 기존 운동 삭제
    final oldValue = _box.get(oldBodyPart);
    if (oldValue != null) {
      final oldExercises = List<String>.from(oldValue);
      oldExercises.remove(oldExerciseName);
      await _box.put(oldBodyPart, oldExercises);
    }

    // 2. 새 운동 추가
    final newValue = _box.get(newBodyPart);
    final newExercises = newValue != null ? List<String>.from(newValue) : <String>[];
    if (!newExercises.contains(newExerciseName)) {
      newExercises.add(newExerciseName);
      await _box.put(newBodyPart, newExercises);
    }
  }

  @override
  Future<void> deleteExercise(String bodyPart, String exerciseName) async {
    final value = _box.get(bodyPart);
    if (value != null) {
      final exercises = List<String>.from(value);
      exercises.remove(exerciseName);
      await _box.put(bodyPart, exercises);
    }
  }

  @override
  Future<void> clearAllData() async => _box.clear();
}
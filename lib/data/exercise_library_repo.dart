import 'package:hive_flutter/hive_flutter.dart';
import '../services/exercise_seeding_service.dart';

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
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();

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

    // 새로운 시딩 서비스로 운동 데이터 초기화
    await _seedingService.initializeAndSeed();
  }

  @override
  Future<Map<String, List<String>>> getLibrary() async {
    // 새로운 시딩 서비스에서 운동 데이터 가져오기
    final exercises = await _seedingService.getAllExercises();
    final map = <String, List<String>>{};
    
    // 부위별로 그룹화
    for (final exercise in exercises) {
      final bodyPart = _getLocalizedBodyPart(exercise.targetPart);
      if (!map.containsKey(bodyPart)) {
        map[bodyPart] = [];
      }
      map[bodyPart]!.add(exercise.nameKr); // 기본적으로 한국어 이름 사용
    }
    
    return map;
  }
  
  String _getLocalizedBodyPart(String targetPart) {
    switch (targetPart.toLowerCase()) {
      case 'chest': return '가슴';
      case 'back': return '등';
      case 'legs': return '하체';
      case 'shoulders': return '어깨';
      case 'arms': return '팔';
      case 'abs': return '복근';
      case 'cardio': return '유산소';
      case 'stretching': return '스트레칭';
      case 'fullbody': return '전신';
      default: return targetPart;
    }
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
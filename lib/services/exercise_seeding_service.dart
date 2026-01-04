import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/exercise_library.dart';

class ExerciseSeedingService {
  static const String _boxName = 'exercise_library_v2';
  static const String _jsonPath = 'assets/data/initial_exercises.json';
  static const String _versionKey = 'seeding_version';
  
  late Box<ExerciseLibraryItem> _box;

  /// 초기화 및 시딩 실행
  Future<void> initializeAndSeed() async {
    try {
      // Hive Box 열기
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<ExerciseLibraryItem>(_boxName);
      } else {
        _box = await Hive.openBox<ExerciseLibraryItem>(_boxName);
      }

      // JSON 파일에서 운동 데이터 로드
      final jsonData = await _loadExercisesFromJson();
      
      // 스마트 시딩 실행
      await _performSmartSeeding(jsonData);
      
      print('✅ 운동 라이브러리 시딩 완료: ${_box.length}개 운동');
    } catch (e) {
      print('❌ 운동 라이브러리 시딩 실패: $e');
      rethrow;
    }
  }

  /// JSON 파일에서 운동 데이터 로드
  Future<List<ExerciseLibraryItem>> _loadExercisesFromJson() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((json) => ExerciseLibraryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ JSON 파일 로드 실패: $e');
      return [];
    }
  }

  /// 스마트 시딩: 신규/업데이트된 운동만 처리
  Future<void> _performSmartSeeding(List<ExerciseLibraryItem> jsonExercises) async {
    if (jsonExercises.isEmpty) {
      print('⚠️ JSON 파일에 운동 데이터가 없습니다.');
      return;
    }

    // 현재 DB의 운동 ID 목록
    final existingIds = _box.keys.cast<String>().toSet();
    final jsonIds = jsonExercises.map((e) => e.id).toSet();

    int insertCount = 0;
    int updateCount = 0;

    for (final jsonExercise in jsonExercises) {
      if (existingIds.contains(jsonExercise.id)) {
        // 기존 운동: 업데이트 필요한지 확인
        final existingExercise = _box.get(jsonExercise.id);
        if (existingExercise != null && _needsUpdate(existingExercise, jsonExercise)) {
          await _box.put(jsonExercise.id, jsonExercise.copyWith(
            createdAt: existingExercise.createdAt, // 생성일은 유지
            updatedAt: DateTime.now(),
          ));
          updateCount++;
          print('🔄 업데이트: ${jsonExercise.nameKr} (${jsonExercise.id})');
        }
      } else {
        // 신규 운동: 추가
        await _box.put(jsonExercise.id, jsonExercise);
        insertCount++;
        print('➕ 신규 추가: ${jsonExercise.nameKr} (${jsonExercise.id})');
      }
    }

    // 삭제된 운동 처리 (JSON에 없지만 DB에 있는 경우)
    final deletedIds = existingIds.difference(jsonIds);
    for (final deletedId in deletedIds) {
      final deletedExercise = _box.get(deletedId);
      if (deletedExercise != null) {
        print('⚠️ JSON에서 제거된 운동 발견: ${deletedExercise.nameKr} (${deletedId})');
        // 실제 삭제는 하지 않고 로그만 남김 (사용자 데이터 보호)
      }
    }

    print('📊 시딩 결과: 신규 ${insertCount}개, 업데이트 ${updateCount}개, 총 ${_box.length}개');
  }

  /// 업데이트가 필요한지 확인
  bool _needsUpdate(ExerciseLibraryItem existing, ExerciseLibraryItem json) {
    return existing.nameKr != json.nameKr ||
           existing.nameEn != json.nameEn ||
           existing.nameJp != json.nameJp ||
           existing.targetPart != json.targetPart ||
           existing.equipmentType != json.equipmentType;
  }

  /// 모든 운동 데이터 조회
  Future<List<ExerciseLibraryItem>> getAllExercises() async {
    return _box.values.toList();
  }

  /// 부위별 운동 조회
  Future<List<ExerciseLibraryItem>> getExercisesByBodyPart(String bodyPart) async {
    return _box.values
        .where((exercise) => exercise.targetPart.toLowerCase() == bodyPart.toLowerCase())
        .toList();
  }

  /// 장비별 운동 조회
  Future<List<ExerciseLibraryItem>> getExercisesByEquipment(String equipment) async {
    return _box.values
        .where((exercise) => exercise.equipmentType.toLowerCase() == equipment.toLowerCase())
        .toList();
  }

  /// 운동 검색 (다국어 지원)
  Future<List<ExerciseLibraryItem>> searchExercises(String query) async {
    if (query.isEmpty) return getAllExercises();
    
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((exercise) =>
            exercise.nameKr.toLowerCase().contains(lowerQuery) ||
            exercise.nameEn.toLowerCase().contains(lowerQuery) ||
            exercise.nameJp.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 통계 정보
  Future<Map<String, int>> getStatistics() async {
    final exercises = await getAllExercises();
    final stats = <String, int>{};
    
    // 부위별 통계
    for (final exercise in exercises) {
      final key = 'bodyPart_${exercise.targetPart}';
      stats[key] = (stats[key] ?? 0) + 1;
    }
    
    // 장비별 통계
    for (final exercise in exercises) {
      final key = 'equipment_${exercise.equipmentType}';
      stats[key] = (stats[key] ?? 0) + 1;
    }
    
    stats['total'] = exercises.length;
    return stats;
  }

  /// Box 닫기
  Future<void> close() async {
    if (_box.isOpen) {
      await _box.close();
    }
  }
}
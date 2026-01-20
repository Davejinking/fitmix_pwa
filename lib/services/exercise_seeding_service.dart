import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/exercise_library.dart';

class ExerciseSeedingService {
  static const String _boxName = 'exercise_library_v2';
  static const String _jsonPath = 'assets/data/initial_exercises.json';
  static const String _versionKey = 'seeding_version';
  
  late Box<ExerciseLibraryItem> _box;
  List<_CachedExercise>? _searchCache;

  /// Hive Box 열기 (초기화)
  Future<void> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<ExerciseLibraryItem>(_boxName);
    } else {
      _box = await Hive.openBox<ExerciseLibraryItem>(_boxName);
    }
  }

  /// 검색 캐시 초기화
  void _invalidateCache() {
    _searchCache = null;
  }

  /// 캐시가 없으면 생성
  Future<void> _ensureCache() async {
    if (_searchCache != null) return;
    if (!_box.isOpen) await _openBox();

    // Box values를 List로 복사하면서 검색 최적화된 형태로 변환
    _searchCache = _box.values.map((e) => _CachedExercise(e)).toList();
  }

  /// 초기화 및 시딩 실행
  Future<void> initializeAndSeed() async {
    try {
      // Hive Box 열기
      await _openBox();

      // JSON 파일에서 운동 데이터 로드
      final jsonData = await _loadExercisesFromJson();
      
      // 스마트 시딩 실행 (내부에서 box.put 호출)
      await _performSmartSeeding(jsonData);
      
      // 시딩 후 캐시 무효화 (변경된 데이터 반영 위해)
      _invalidateCache();

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
    await _ensureCache();
    return _searchCache!.map((e) => e.item).toList();
  }

  /// 커스텀 운동 추가
  Future<void> addCustomExercise({
    required String name,
    required String bodyPart,
    String equipmentType = 'Bodyweight',
  }) async {
    // 🔥 Box가 열려있는지 확인 및 초기화
    await _openBox();

    // 커스텀 운동 ID 생성 (custom_ 접두사 사용)
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    
    final customExercise = ExerciseLibraryItem(
      id: id,
      nameKr: name,
      nameEn: name,
      nameJp: name,
      targetPart: bodyPart,
      equipmentType: equipmentType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _box.put(id, customExercise);
    _invalidateCache(); // 캐시 업데이트 필요
    print('✅ 커스텀 운동 추가: $name ($id)');
  }

  /// 부위별 운동 조회
  Future<List<ExerciseLibraryItem>> getExercisesByBodyPart(String bodyPart) async {
    await _ensureCache();
    final lowerPart = bodyPart.toLowerCase();

    return _searchCache!
        .where((e) => e.targetPartLower == lowerPart)
        .map((e) => e.item)
        .toList();
  }

  /// 장비별 운동 조회
  Future<List<ExerciseLibraryItem>> getExercisesByEquipment(String equipment) async {
    await _ensureCache();
    final lowerEq = equipment.toLowerCase();

    return _searchCache!
        .where((e) => e.equipmentTypeLower == lowerEq)
        .map((e) => e.item)
        .toList();
  }

  /// 운동 검색 (다국어 지원)
  Future<List<ExerciseLibraryItem>> searchExercises(String query) async {
    await _ensureCache();
    if (query.isEmpty) return _searchCache!.map((e) => e.item).toList();
    
    final lowerQuery = query.toLowerCase();
    return _searchCache!
        .where((cached) => cached.matches(lowerQuery))
        .map((e) => e.item)
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

/// 검색 최적화를 위한 래퍼 클래스
class _CachedExercise {
  final ExerciseLibraryItem item;
  final String nameKrLower;
  final String nameEnLower;
  final String nameJpLower;
  final String targetPartLower;
  final String equipmentTypeLower;

  _CachedExercise(this.item)
      : nameKrLower = item.nameKr.toLowerCase(),
        nameEnLower = item.nameEn.toLowerCase(),
        nameJpLower = item.nameJp.toLowerCase(),
        targetPartLower = item.targetPart.toLowerCase(),
        equipmentTypeLower = item.equipmentType.toLowerCase();

  bool matches(String lowerQuery) {
    return nameKrLower.contains(lowerQuery) ||
           nameEnLower.contains(lowerQuery) ||
           nameJpLower.contains(lowerQuery);
  }
}

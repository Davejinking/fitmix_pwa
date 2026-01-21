import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/exercise_db.dart';

/// Top-level function for parsing exercises in an isolate
List<ExerciseDB> parseExercises(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((json) => ExerciseDB.fromJson(json)).toList();
}

/// ExerciseDB 로컬 데이터 서비스 (JSON 파일 기반)
class ExerciseDBService {
  List<ExerciseDB>? _cachedExercises;
  
  /// 로컬 JSON 파일에서 모든 운동 데이터 로드
  Future<List<ExerciseDB>> _loadExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      // 백그라운드 아이솔레이트에서 JSON 파싱 수행
      _cachedExercises = await compute(_parseExercises, jsonString);
      return _cachedExercises!;
    } catch (e) {
      throw Exception('로컬 운동 데이터 로드 실패: $e');
    }
  }

  /// 모든 운동 가져오기
  Future<List<ExerciseDB>> getAllExercises({int limit = 1000}) async {
    final exercises = await _loadExercises();
    return exercises.take(limit).toList();
  }

  /// 부위별 운동 가져오기
  Future<List<ExerciseDB>> getExercisesByBodyPart(String bodyPart) async {
    final exercises = await _loadExercises();
    return exercises.where((ex) => ex.bodyPart == bodyPart).toList();
  }

  /// 장비별 운동 가져오기
  Future<List<ExerciseDB>> getExercisesByEquipment(String equipment) async {
    final exercises = await _loadExercises();
    return exercises.where((ex) => ex.equipment == equipment).toList();
  }

  /// 운동 검색 (이름으로)
  Future<List<ExerciseDB>> searchExercises(String query) async {
    final exercises = await _loadExercises();
    final lowerQuery = query.toLowerCase();
    return exercises.where((ex) => ex.name.toLowerCase().contains(lowerQuery)).toList();
  }

  /// 사용 가능한 부위 목록
  static const List<String> bodyParts = [
    'back',
    'cardio',
    'chest',
    'lower arms',
    'lower legs',
    'neck',
    'shoulders',
    'upper arms',
    'upper legs',
    'waist',
  ];

  /// 사용 가능한 장비 목록
  static const List<String> equipments = [
    'assisted',
    'band',
    'barbell',
    'body weight',
    'cable',
    'dumbbell',
    'kettlebell',
    'leverage machine',
    'medicine ball',
    'olympic barbell',
    'resistance band',
    'roller',
    'rope',
    'skierg machine',
    'sled machine',
    'smith machine',
    'stability ball',
    'stationary bike',
    'tire',
    'trap bar',
    'weighted',
    'wheel roller',
  ];
}

/// JSON 파싱을 수행하는 탑레벨 함수 (compute용)
List<ExerciseDB> _parseExercises(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((json) => ExerciseDB.fromJson(json)).toList();
}

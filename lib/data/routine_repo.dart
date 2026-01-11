import 'package:hive_flutter/hive_flutter.dart';
import '../models/routine.dart';

/// 루틴 데이터 저장소 인터페이스
abstract class RoutineRepo {
  /// 저장소 초기화
  Future<void> init();
  
  /// 모든 루틴 조회 (최근 사용순)
  Future<List<Routine>> listAll();
  
  /// 특정 루틴 조회
  Future<Routine?> get(String id);
  
  /// 루틴 저장
  Future<void> save(Routine routine);
  
  /// 루틴 삭제
  Future<void> delete(String id);
  
  /// 루틴 사용 시간 업데이트
  Future<void> updateLastUsed(String id);
  
  /// 모든 루틴 삭제
  Future<void> clearAll();
}

class HiveRoutineRepo implements RoutineRepo {
  static const boxName = 'routines';
  late Box<Routine> _box;

  @override
  Future<void> init() async {
    // 어댑터 중복 등록 방지
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(RoutineAdapter());
    }

    // 이미 열려 있으면 재사용, 아니면 오픈
    try {
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<Routine>(boxName);
      } else {
        _box = await Hive.openBox<Routine>(boxName);
      }
    } catch (e) {
      // TypeId 변경으로 인한 에러 발생 시 박스 삭제 후 재생성
      print('⚠️ Routine 박스 오류 감지: $e');
      print('🔄 박스 재생성 중...');
      
      try {
        await Hive.deleteBoxFromDisk(boxName);
        _box = await Hive.openBox<Routine>(boxName);
        print('✅ Routine 박스 재생성 완료');
      } catch (deleteError) {
        print('❌ 박스 재생성 실패: $deleteError');
        rethrow;
      }
    }
  }

  @override
  Future<List<Routine>> listAll() async {
    final list = _box.values.toList();
    // 최근 사용순으로 정렬 (사용한 적 없으면 생성일 기준)
    list.sort((a, b) {
      final aTime = a.lastUsedAt ?? a.createdAt;
      final bTime = b.lastUsedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    return list;
  }

  @override
  Future<Routine?> get(String id) async => _box.get(id);

  @override
  Future<void> save(Routine routine) async => _box.put(routine.id, routine);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<void> updateLastUsed(String id) async {
    final routine = await get(id);
    if (routine != null) {
      routine.lastUsedAt = DateTime.now();
      await save(routine);
    }
  }

  @override
  Future<void> clearAll() async => _box.clear();
}

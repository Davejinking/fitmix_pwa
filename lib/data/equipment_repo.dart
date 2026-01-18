import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/equipment.dart';

/// 장비 데이터 저장소 인터페이스
abstract class EquipmentRepo {
  Future<void> init();
  Future<List<Equipment>> listAll();
  Future<Equipment?> get(String id);
  Future<void> save(Equipment equipment);
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<void> updateStats(String id, double volumeAdded, int setsAdded);
  Future<List<Equipment>> getByCategory(EquipmentCategory category);
  Future<List<Equipment>> getLinkedEquipment(String exerciseName);
  ValueListenable<Box<Equipment>> listenable();
}

class HiveEquipmentRepo implements EquipmentRepo {
  static const boxName = 'equipment';
  late Box<Equipment> _box;

  @override
  Future<void> init() async {
    // 어댑터 중복 등록 방지
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(EquipmentAdapter());
    }

    try {
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<Equipment>(boxName);
      } else {
        _box = await Hive.openBox<Equipment>(boxName);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Equipment 박스 오류: $e');
        print('🔄 박스 재생성 중...');
      }
      
      try {
        await Hive.deleteBoxFromDisk(boxName);
        _box = await Hive.openBox<Equipment>(boxName);
        if (kDebugMode) print('✅ Equipment 박스 재생성 완료');
      } catch (deleteError) {
        if (kDebugMode) print('❌ 박스 재생성 실패: $deleteError');
        rethrow;
      }
    }
  }

  @override
  Future<List<Equipment>> listAll() async {
    final list = _box.values.toList();
    // 최근 등록순 정렬
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Equipment?> get(String id) async => _box.get(id);

  @override
  Future<void> save(Equipment equipment) async => _box.put(equipment.id, equipment);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Future<void> clearAll() async => _box.clear();

  @override
  Future<void> updateStats(String id, double volumeAdded, int setsAdded) async {
    final equipment = await get(id);
    if (equipment != null) {
      equipment.totalVolumeLifted += volumeAdded;
      equipment.totalSetsCompleted += setsAdded;
      await save(equipment);
    }
  }

  @override
  Future<List<Equipment>> getByCategory(EquipmentCategory category) async {
    final all = await listAll();
    return all.where((e) => e.category == category).toList();
  }

  @override
  Future<List<Equipment>> getLinkedEquipment(String exerciseName) async {
    final all = await listAll();
    return all.where((e) => 
      e.linkedExercises.any((linked) => 
        exerciseName.toLowerCase().contains(linked.toLowerCase())
      )
    ).toList();
  }

  @override
  ValueListenable<Box<Equipment>> listenable() => _box.listenable();
}

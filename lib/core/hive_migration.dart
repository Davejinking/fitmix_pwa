import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

/// Hive 데이터베이스 마이그레이션 유틸리티
class HiveMigration {
  /// 모든 Hive 박스를 삭제하고 초기화
  /// TypeId 변경이나 스키마 변경 시 사용
  static Future<void> clearAllBoxes() async {
    try {
      // Hive 초기화
      await Hive.initFlutter();
      
      // 열려있는 모든 박스 닫기
      await Hive.close();
      
      // Hive 디렉토리 삭제
      final dir = Directory(Hive.box.path ?? '');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      
      print('✅ Hive 데이터베이스 초기화 완료');
    } catch (e) {
      print('❌ Hive 초기화 실패: $e');
    }
  }
  
  /// 특정 박스만 삭제
  static Future<void> deleteBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      print('✅ $boxName 박스 삭제 완료');
    } catch (e) {
      print('❌ $boxName 박스 삭제 실패: $e');
    }
  }
}

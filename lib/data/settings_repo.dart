import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 앱 설정(테마 등) 데이터 저장소 인터페이스
abstract class SettingsRepo {
  Future<void> init();
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode themeMode);
  Future<void> clearAllData();
}

class HiveSettingsRepo implements SettingsRepo {
  static const String boxName = 'settings';
  static const String themeModeKey = 'theme_mode';
  late Box<String> _box;

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<String>(boxName);
    } else {
      _box = await Hive.openBox<String>(boxName);
    }
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final themeString = _box.get(themeModeKey, defaultValue: ThemeMode.system.name);
    return ThemeMode.values.firstWhere((e) => e.name == themeString, orElse: () => ThemeMode.system);
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _box.put(themeModeKey, themeMode.name);
  }

  @override
  Future<void> clearAllData() async => _box.clear();
}
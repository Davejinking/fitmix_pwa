import 'package:flutter/material.dart';

/// 전역 테마 변경 알림
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// 전역 인스턴스
final themeNotifier = ThemeNotifier();

// lib/core/iron_theme.dart
import 'package:flutter/material.dart';

class IronTheme {
  // --- Color Palette ---
  static const Color background = Color(0xFF121212); // 찐 블랙
  static const Color surface = Color(0xFF1E1E1E);    // 카드/팝업 배경
  static const Color surfaceHighlight = Color(0xFF2C2C2C); // 달력 헤더 등 강조 배경
  static const Color primary = Color(0xFF4A9EFF);    // Neon Blue
  static const Color secondary = Color(0xFFFF6B35);  // Neon Orange
  static const Color danger = Color(0xFFCF6679);
  static const Color textHigh = Colors.white;        // 기본 텍스트
  static const Color textMedium = Color(0xFFAAAAAA); // 보조 텍스트

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      // [핵심] Material 3 컬러 스키마 강제 지정 (이게 있어야 팝업이 안 하얘짐)
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: textHigh,
        secondary: secondary,
        onSecondary: textHigh,
        surface: surface,        // 다이얼로그 기본 배경
        onSurface: textHigh,     // 다이얼로그 텍스트
        surfaceContainerHigh: surfaceHighlight, // 달력 선택창 같은 팝업 배경
        error: danger,
        onError: textHigh,
      ),

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold, 
          color: textHigh
        ),
        iconTheme: IconThemeData(color: textHigh),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
      ),

      // [핵심] 다이얼로그 테마 - 이게 캘린더 배경을 결정함
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),

      // [중요] 달력 테마 완벽 적용
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent, // M3 특유의 틴트 효과 제거
        headerBackgroundColor: surfaceHighlight, // 연도/날짜 헤더 배경
        headerForegroundColor: textHigh,         // 헤더 글자색
        dayForegroundColor: WidgetStateProperty.all(textHigh),
        yearForegroundColor: WidgetStateProperty.all(textHigh),
        todayBackgroundColor: WidgetStateProperty.all(primary),
        todayForegroundColor: WidgetStateProperty.all(textHigh),
        yearOverlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.1)),
        dayOverlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.1)),
      ),

      // 다이얼로그 하단 '확인/취소' 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary, // 버튼 글자색 (Blue)
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 바텀 시트 테마
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
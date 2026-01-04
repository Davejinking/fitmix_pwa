import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 상수들을 중앙 관리
class AppConstants {
  // 앱 정보
  static const String appName = 'Lifto';
  static const String appVersion = '1.0.0';
  
  // 날짜 관련
  static final DateTime firstDay = DateTime(2010, 1, 1);
  static final DateTime lastDay = DateTime(2035, 12, 31);
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'yyyy년 MM월 dd일 (E)';
  
  // UI 관련
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardElevation = 0.0;
  static const double progressBarHeight = 8.0;
  static const double cardRadius = 16.0; // 통일된 카드 모서리

  // Apple HIG 스타일 다크 테마
  static const Color primaryColor = Color(0xFF007AFF); // 스카이 블루
  static const Color accentColor = Color(0xFFCCFF00); // 네온 라임 (선택적 사용)
  static const Color backgroundColor = Color(0xFF121212); // 다크 배경
  static const Color cardColor = Color(0xFF1E1E1E); // 카드 배경
  static const Color textPrimary = Color(0xFFFFFFFF); // 흰색 텍스트
  static const Color textSecondary = Color(0xFFAAAAAA); // 회색 텍스트
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Pretendard',
    useMaterial3: false,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: const Color(0xFF2C2C2E),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: cardColor,
      onSurface: textPrimary,
      surfaceContainerHighest: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
    ),
  );
  
  // 차트 관련
  static const double chartAspectRatio = 1.7;
  static const double chartBarWidth = 16.0;
  static const double chartMinY = 5.0;
  static const double chartMaxY = 10.0;
  
  // 운동 부위
  static const List<String> bodyParts = [
    '가슴',
    '등', 
    '어깨',
    '팔',
    '하체',
    '복근',
    '유산소'
  ];
  
  // 기본 운동 라이브러리 - 더 이상 사용하지 않음 (ExerciseSeedingService로 대체)
  // 레거시 호환성을 위해 빈 맵 유지
  static const Map<String, List<String>> defaultExerciseLibrary = {};
  
  // 목표 관련
  static const Map<String, int> defaultGoals = {
    'workoutDays': 20,
    'totalSets': 120,
  };
  
  // 테스트 데이터
  static const List<double> testWeeklyData = [2, 3, 0, 4, 1, 5, 3];
  static const Map<String, int> testGoalData = {
    'workoutDays': 12,
    'totalSets': 86,
  };
}

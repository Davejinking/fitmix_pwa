import 'package:flutter/material.dart';
import 'burn_fit_style.dart';

/// 앱 전체에서 사용되는 상수들을 중앙 관리
class AppConstants {
  // 앱 정보
  static const String appName = 'FitMix PS0';
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
  static const double cardElevation = 2.0;
  static const double progressBarHeight = 8.0;

  // 테마
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Pretendard',
    useMaterial3: false,
    scaffoldBackgroundColor: BurnFitStyle.white,
    cardColor: BurnFitStyle.lightGray,
    colorSchemeSeed: BurnFitStyle.primaryBlue,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Pretendard',
    useMaterial3: false,
    scaffoldBackgroundColor: const Color(0xFF121212), // 다크 모드 기본 배경색
    cardColor: const Color(0xFF1E1E1E), // 다크 모드 카드 배경색
    dividerColor: Colors.grey[800],
    colorScheme: const ColorScheme.dark(
      primary: BurnFitStyle.primaryBlue,
      secondary: BurnFitStyle.primaryBlue,
      surface: Color(0xFF1E1E1E),
      onSurface: BurnFitStyle.white,
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
  
  // 기본 운동 라이브러리
  static const Map<String, List<String>> defaultExerciseLibrary = {
    '가슴': ['벤치프레스', '인클라인 덤벨프레스', '체스트 프레스'],
    '등': ['랫풀다운', '바벨 로우', '시티드 로우'],
    '어깨': ['사이드 레터럴', '숄더 프레스', '리어 델트 플라이'],
    '팔': ['바벨 컬', '케이블 푸시다운', '해머 컬'],
    '하체': ['스쿼트', '레그 프레스', '레그 컬'],
    '복근': ['크런치', '행잉 레그레이즈', '케이블 크런치'],
    '유산소': ['싸이클', '런닝머신', '로잉'],
  };
  
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

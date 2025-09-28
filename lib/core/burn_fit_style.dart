import 'package:flutter/material.dart';

/// BURN FIT 앱의 디자인 시스템 (색상 및 텍스트 스타일)
class BurnFitStyle {
  // 1. 기본 스타일 가이드 (Style Guide)
  // 주요 색상 (Colors)
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color lightGray = Color(0xFFF2F2F7);
  static const Color mediumGray = Color(0xFFE5E5EA);
  static const Color darkGrayText = Color(0xFF1C1C1E);
  static const Color secondaryGrayText = Color(0xFF8E8E93);
  static const Color warningRed = Color(0xFFFF3B30);
  static const Color white = Color(0xFFFFFFFF);

  // 주요 폰트 (Typography)
  static const TextStyle title1 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: darkGrayText,
  );

  static const TextStyle title2 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: darkGrayText,
  );

  static const TextStyle body = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 17,
    color: darkGrayText,
  );

  static const TextStyle caption = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: secondaryGrayText,
  );
}
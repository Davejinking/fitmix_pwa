// lib/models/muscle_group.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// 🎯 MuscleGroup Enum - Single Source of Truth for Body Part Categories
/// 
/// This enum defines all muscle groups used in Iron Log with their:
/// - Color coding (high-contrast neon colors for dark mode)
/// - Abbreviations (2-letter codes for compact display)
/// - Localized labels (via extension method)
enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  abs,
  cardio,
  stretching,
  fullBody,
}

/// Extension methods for MuscleGroup enum
extension MuscleGroupExtension on MuscleGroup {
  /// Get the high-contrast neon color for this muscle group
  Color get color {
    switch (this) {
      case MuscleGroup.chest:
        return const Color(0xFFFF5252); // Neon Red
      case MuscleGroup.back:
        return const Color(0xFF448AFF); // Electric Blue
      case MuscleGroup.legs:
        return const Color(0xFFFFD740); // Deep Yellow/Amber
      case MuscleGroup.shoulders:
        return const Color(0xFFE040FB); // Neon Purple
      case MuscleGroup.arms:
        return const Color(0xFF18FFFF); // Cyan Accent
      case MuscleGroup.abs:
        return const Color(0xFF69F0AE); // Neon Green
      case MuscleGroup.cardio:
        return const Color(0xFFFFAB40); // Neon Orange
      case MuscleGroup.stretching:
        return const Color(0xFF64FFDA); // Teal Accent
      case MuscleGroup.fullBody:
        return const Color(0xFFFFFFFF); // Pure White
    }
  }

  /// Get the 2-letter abbreviation for this muscle group
  String get abbreviation {
    switch (this) {
      case MuscleGroup.chest:
        return "CH";
      case MuscleGroup.back:
        return "BK";
      case MuscleGroup.legs:
        return "LG";
      case MuscleGroup.shoulders:
        return "SH";
      case MuscleGroup.arms:
        return "AR";
      case MuscleGroup.abs:
        return "AB";
      case MuscleGroup.cardio:
        return "CD";
      case MuscleGroup.stretching:
        return "ST";
      case MuscleGroup.fullBody:
        return "FB";
    }
  }

  /// Get the localized label for this muscle group
  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case MuscleGroup.chest:
        return l10n.chest;
      case MuscleGroup.back:
        return l10n.back;
      case MuscleGroup.legs:
        return l10n.legs;
      case MuscleGroup.shoulders:
        return l10n.shoulders;
      case MuscleGroup.arms:
        return l10n.arms;
      case MuscleGroup.abs:
        return l10n.abs;
      case MuscleGroup.cardio:
        return l10n.cardio;
      case MuscleGroup.stretching:
        return l10n.stretching;
      case MuscleGroup.fullBody:
        return l10n.fullBody;
    }
  }

  /// Get all muscle groups as a list
  static List<MuscleGroup> get all => MuscleGroup.values;
}

/// Helper methods for parsing strings to MuscleGroup
extension MuscleGroupParsing on MuscleGroup {

  // Optimization: Static sets for O(1) lookup and avoiding list allocation
  static const Set<String> _chestKeywords = {'Chest', 'chest', 'CHEST', '가슴', '胸'};
  static const Set<String> _backKeywords = {'Back', 'back', 'BACK', '등', '背中'};
  static const Set<String> _legsKeywords = {'Legs', 'legs', 'LEGS', 'Leg', 'leg', '하체', '下半身', '脚', '다리'};
  static const Set<String> _shouldersKeywords = {'Shoulders', 'shoulders', 'SHOULDERS', 'Shoulder', 'shoulder', '어깨', '肩'};
  static const Set<String> _armsKeywords = {'Arms', 'arms', 'ARMS', 'Arm', 'arm', '팔', '腕'};
  static const Set<String> _absKeywords = {'Abs', 'abs', 'ABS', 'Core', 'core', 'CORE', '복근', '腹筋', '코어'};
  static const Set<String> _cardioKeywords = {'Cardio', 'cardio', 'CARDIO', '유산소', '有酸素', 'カーディオ'};
  static const Set<String> _stretchingKeywords = {'Stretching', 'stretching', 'STRETCHING', 'Stretch', 'stretch', '스트레칭', 'ストレッチ'};
  static const Set<String> _fullBodyKeywords = {
    'Full Body', 'full body', 'FULL BODY', 'FullBody', 'fullbody', 'FULLBODY',
    'Full-Body', 'full-body', 'Fullbody',
    '전신', '全身', '全身運動'
  };

  /// Parse a string to MuscleGroup (supports English, Korean, Japanese)
  /// Returns null if no match is found
  static MuscleGroup? fromString(String value) {
    final input = value.trim();
    
    // CHEST (Red) - English, Korean, Japanese
    if (_chestKeywords.contains(input)) return MuscleGroup.chest;
    
    // BACK (Blue) - English, Korean, Japanese
    if (_backKeywords.contains(input)) return MuscleGroup.back;
    
    // LEGS (Yellow) - English, Korean, Japanese
    if (_legsKeywords.contains(input)) return MuscleGroup.legs;
    
    // SHOULDERS (Purple) - English, Korean, Japanese
    if (_shouldersKeywords.contains(input)) return MuscleGroup.shoulders;
    
    // ARMS (Cyan) - English, Korean, Japanese
    if (_armsKeywords.contains(input)) return MuscleGroup.arms;
    
    // ABS (Green) - English, Korean, Japanese
    if (_absKeywords.contains(input)) return MuscleGroup.abs;
    
    // CARDIO (Orange) - English, Korean, Japanese
    if (_cardioKeywords.contains(input)) return MuscleGroup.cardio;
    
    // STRETCHING (Teal) - English, Korean, Japanese
    if (_stretchingKeywords.contains(input)) return MuscleGroup.stretching;
    
    // FULL BODY (White) - English, Korean, Japanese
    if (_fullBodyKeywords.contains(input)) return MuscleGroup.fullBody;
    
    // Case-insensitive fallback check for "full" and "body" keywords
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('full') && lowerInput.contains('body')) {
      return MuscleGroup.fullBody;
    }
    
    // No match found
    return null;
  }
  
  /// Parse a string to MuscleGroup with a fallback default
  /// This is useful when you always need a MuscleGroup (never null)
  static MuscleGroup fromStringWithFallback(String value, {MuscleGroup fallback = MuscleGroup.fullBody}) {
    return fromString(value) ?? fallback;
  }
  
  /// Debug helper: Get a detailed parsing result with the original input
  /// Useful for troubleshooting why certain strings aren't matching
  static String debugParse(String value) {
    final result = fromString(value);
    if (result != null) {
      return 'SUCCESS: "$value" → ${result.name} (${result.abbreviation})';
    } else {
      return 'FAILED: "$value" → No match found. Check spelling and add to fromString() if needed.';
    }
  }
}

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
  /// Parse a string to MuscleGroup (case-insensitive)
  static MuscleGroup? fromString(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'chest':
      case '가슴':
      case '胸':
        return MuscleGroup.chest;
      case 'back':
      case '등':
      case '背中':
        return MuscleGroup.back;
      case 'legs':
      case '하체':
      case '脚':
        return MuscleGroup.legs;
      case 'shoulders':
      case '어깨':
      case '肩':
        return MuscleGroup.shoulders;
      case 'arms':
      case '팔':
      case '腕':
        return MuscleGroup.arms;
      case 'abs':
      case '복근':
      case '腹筋':
        return MuscleGroup.abs;
      case 'cardio':
      case '유산소':
      case '有酸素':
        return MuscleGroup.cardio;
      case 'stretching':
      case '스트레칭':
      case 'ストレッチ':
        return MuscleGroup.stretching;
      case 'fullbody':
      case 'full body':
      case '전신':
      case '全身':
        return MuscleGroup.fullBody;
      default:
        return null;
    }
  }
}

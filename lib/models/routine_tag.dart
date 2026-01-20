// lib/models/routine_tag.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Routine Tag with Color Support
/// Provides preset tags with localized names and neon colors
class RoutineTag {
  final String key; // Internal identifier (e.g., 'push', 'pull')
  final Color color;
  
  const RoutineTag({
    required this.key,
    required this.color,
  });
  
  /// Get localized label for this tag
  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key.toLowerCase()) {
      case 'push':
        return l10n.localeName == 'ja' ? 'プッシュ' 
             : l10n.localeName == 'ko' ? '미는 운동'
             : 'PUSH';
      case 'pull':
        return l10n.localeName == 'ja' ? 'プル'
             : l10n.localeName == 'ko' ? '당기는 운동'
             : 'PULL';
      case 'legs':
        return l10n.localeName == 'ja' ? '脚'
             : l10n.localeName == 'ko' ? '하체'
             : 'LEGS';
      case 'upper':
        return l10n.localeName == 'ja' ? '上半身'
             : l10n.localeName == 'ko' ? '상체'
             : 'UPPER';
      case 'lower':
        return l10n.localeName == 'ja' ? '下半身'
             : l10n.localeName == 'ko' ? '하체'
             : 'LOWER';
      case 'fullbody':
        return l10n.localeName == 'ja' ? '全身'
             : l10n.localeName == 'ko' ? '전신'
             : 'FULL BODY';
      default:
        return key.toUpperCase();
    }
  }
  
  /// System preset tags with neon colors
  static List<RoutineTag> get systemPresets => [
    const RoutineTag(key: 'push', color: Color(0xFFFF5252)),      // Neon Red
    const RoutineTag(key: 'pull', color: Color(0xFF448AFF)),      // Electric Blue
    const RoutineTag(key: 'legs', color: Color(0xFFFFD740)),      // Deep Yellow
    const RoutineTag(key: 'upper', color: Color(0xFFE040FB)),     // Neon Purple
    const RoutineTag(key: 'lower', color: Color(0xFFFFAB40)),     // Neon Orange
    const RoutineTag(key: 'fullbody', color: Color(0xFFFFFFFF)),  // Pure White
  ];
  
  /// Available neon colors for custom tags
  static List<Color> get neonPalette => [
    const Color(0xFFFF5252), // Neon Red
    const Color(0xFF448AFF), // Electric Blue
    const Color(0xFFFFD740), // Deep Yellow
    const Color(0xFFE040FB), // Neon Purple
    const Color(0xFF18FFFF), // Cyan Accent
    const Color(0xFF69F0AE), // Neon Green
    const Color(0xFFFFAB40), // Neon Orange
    const Color(0xFF64FFDA), // Teal Accent
    const Color(0xFFFFFFFF), // Pure White
  ];
  
  /// Find preset tag by key
  static RoutineTag? findPreset(String key) {
    try {
      return systemPresets.firstWhere(
        (tag) => tag.key.toLowerCase() == key.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get color for a tag key (preset or default)
  static Color getColorForKey(String key, {Color defaultColor = Colors.grey}) {
    final preset = findPreset(key);
    return preset?.color ?? defaultColor;
  }
  
  /// Get color for a localized tag name (supports multilingual)
  /// This is useful for filter bars where tags are displayed in user's locale
  static Color getColorForLocalizedName(String tagName) {
    final name = tagName.trim();
    
    // PUSH (Red)
    if (['PUSH', 'プッシュ', '미는 운동'].contains(name)) {
      return const Color(0xFFFF5252);
    }
    
    // PULL (Blue)
    if (['PULL', 'プル', '당기는 운동'].contains(name)) {
      return const Color(0xFF448AFF);
    }
    
    // LEGS (Yellow)
    if (['LEGS', '脚', '하체'].contains(name)) {
      return const Color(0xFFFFD740);
    }
    
    // UPPER (Purple)
    if (['UPPER', '上半身', '상체'].contains(name)) {
      return const Color(0xFFE040FB);
    }
    
    // LOWER (Orange)
    if (['LOWER', '下半身', '하체'].contains(name)) {
      return const Color(0xFFFFAB40);
    }
    
    // FULL BODY (White)
    if (['FULL BODY', '全身', '전신'].contains(name)) {
      return const Color(0xFFFFFFFF);
    }
    
    // 🔥 FIX: Default for custom tags - use Neon Green instead of white
    // This makes custom tags more visible and distinct
    return const Color(0xFF69F0AE); // Neon Green
  }
}

/// Custom tag with user-defined name and color
class CustomRoutineTag {
  final String name;
  final Color color;
  
  const CustomRoutineTag({
    required this.name,
    required this.color,
  });
  
  /// Convert to storage format (name only, color derived from name or default)
  String toStorageString() => name;
  
  /// Create from storage string with optional color
  factory CustomRoutineTag.fromString(String name, {Color? color}) {
    return CustomRoutineTag(
      name: name,
      color: color ?? RoutineTag.getColorForKey(name, defaultColor: const Color(0xFF69F0AE)),
    );
  }
}

// lib/core/body_part_colors.dart
import 'package:flutter/material.dart';
import '../models/muscle_group.dart';

/// 🎨 Body Part Color System - Iron Log Color-Coded Categories
/// 
/// This is a utility class that wraps the MuscleGroup enum for backward compatibility.
/// The MuscleGroup enum is the single source of truth for colors and abbreviations.
class BodyPartColors {
  // --- Color Definitions (delegated to MuscleGroup enum) ---
  static Color get chest => MuscleGroup.chest.color;
  static Color get back => MuscleGroup.back.color;
  static Color get legs => MuscleGroup.legs.color;
  static Color get shoulders => MuscleGroup.shoulders.color;
  static Color get arms => MuscleGroup.arms.color;
  static Color get abs => MuscleGroup.abs.color;
  static Color get cardio => MuscleGroup.cardio.color;
  static Color get stretching => MuscleGroup.stretching.color;
  static Color get fullBody => MuscleGroup.fullBody.color;
  
  /// Get color for a body part (case-insensitive)
  static Color getColor(String bodyPart) {
    final muscleGroup = MuscleGroupParsing.fromString(bodyPart);
    return muscleGroup?.color ?? Colors.grey; // Fallback
  }
  
  /// Get abbreviation for a body part (case-insensitive)
  static String getAbbreviation(String bodyPart) {
    final muscleGroup = MuscleGroupParsing.fromString(bodyPart);
    return muscleGroup?.abbreviation ?? '??';
  }
  
  /// Get all available body part keys (for filters)
  static const List<String> allBodyParts = [
    'chest',
    'back',
    'legs',
    'shoulders',
    'arms',
    'abs',
    'cardio',
    'stretching',
    'fullBody',
  ];
}

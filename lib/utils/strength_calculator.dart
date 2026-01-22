import 'package:flutter/material.dart';

/// Strength Calculator - Wilks Score, BW Ratio, Tier System
class StrengthCalculator {
  /// Calculate Wilks Score (Simplified)
  /// Formula: Total Weight * Coefficient based on bodyweight
  /// Note: This is a simplified version for MVP
  static double calculateWilks(double totalWeight, double bodyWeight) {
    if (bodyWeight <= 0) return 0;
    
    // Simplified coefficient calculation
    // Real Wilks uses a complex polynomial formula
    // For MVP, we use a simplified multiplier
    final coefficient = _getWilksCoefficient(bodyWeight);
    return totalWeight * coefficient;
  }
  
  /// Get simplified Wilks coefficient based on bodyweight
  static double _getWilksCoefficient(double bodyWeight) {
    // Simplified coefficient curve
    // Lower bodyweight = higher coefficient (more impressive)
    if (bodyWeight < 60) return 1.5;
    if (bodyWeight < 70) return 1.3;
    if (bodyWeight < 80) return 1.2;
    if (bodyWeight < 90) return 1.1;
    if (bodyWeight < 100) return 1.05;
    return 1.0;
  }
  
  /// Calculate Bodyweight Ratio
  /// Formula: Total Weight / Bodyweight
  static String calculateRatio(double totalWeight, double bodyWeight) {
    if (bodyWeight <= 0) return '--';
    
    final ratio = totalWeight / bodyWeight;
    return '${ratio.toStringAsFixed(1)}x';
  }
  
  /// Calculate Strength Tier based on BW Ratio
  /// Returns tier name and color
  static StrengthTier calculateTier(double totalWeight, double bodyWeight) {
    if (bodyWeight <= 0 || totalWeight <= 0) {
      return StrengthTier(
        name: 'BEGINNER',
        color: const Color(0xFFFFFFFF), // White
      );
    }
    
    final ratio = totalWeight / bodyWeight;
    
    if (ratio >= 5.0) {
      return StrengthTier(
        name: 'ELITE',
        color: const Color(0xFFFFD700), // Gold
      );
    } else if (ratio >= 4.0) {
      return StrengthTier(
        name: 'ADVANCED',
        color: const Color(0xFF9C27B0), // Purple
      );
    } else if (ratio >= 3.0) {
      return StrengthTier(
        name: 'INTERMEDIATE',
        color: const Color(0xFF2962FF), // Electric Blue
      );
    } else {
      return StrengthTier(
        name: 'BEGINNER',
        color: const Color(0xFFFFFFFF), // White
      );
    }
  }
}

/// Strength Tier Data Class
class StrengthTier {
  final String name;
  final Color color;
  
  StrengthTier({
    required this.name,
    required this.color,
  });
}

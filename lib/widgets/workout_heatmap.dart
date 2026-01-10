import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GitHub-style Contribution Heatmap for Workout Tracking
/// Industrial/Noir aesthetic with intensity-based color scaling
class WorkoutHeatmap extends StatelessWidget {
  final Map<DateTime, double> workoutData; // DateTime -> Volume (kg)
  final int monthsToShow;
  final Function(DateTime)? onDayTap;

  const WorkoutHeatmap({
    super.key,
    required this.workoutData,
    this.monthsToShow = 6,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - monthsToShow, endDate.day);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          _buildMonthLabels(startDate, endDate),
          const SizedBox(height: 8),
          // Heatmap grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildHeatmapGrid(startDate, endDate),
          ),
          const SizedBox(height: 12),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthLabels(DateTime start, DateTime end) {
    final months = <String>[];
    final monthWidths = <double>[];
    
    DateTime current = DateTime(start.year, start.month, 1);
    while (current.isBefore(end) || current.month == end.month) {
      final monthName = DateFormat('MMM').format(current);
      months.add(monthName.toUpperCase());
      
      // Calculate weeks in this month
      final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
      final weeksInMonth = (daysInMonth / 7).ceil();
      monthWidths.add(weeksInMonth * 16.0); // 14px box + 2px gutter
      
      current = DateTime(current.year, current.month + 1, 1);
    }

    return SizedBox(
      height: 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(months.length, (index) {
            return SizedBox(
              width: monthWidths[index],
              child: Text(
                months[index],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF505050),
                  letterSpacing: 0.5,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(DateTime start, DateTime end) {
    // Calculate weeks needed
    final totalDays = end.difference(start).inDays + 1;
    final weeks = (totalDays / 7).ceil();
    
    // Adjust start to Monday
    final startMonday = start.subtract(Duration(days: start.weekday - 1));
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(weeks, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Column(
            children: List.generate(7, (dayIndex) {
              final date = startMonday.add(Duration(days: weekIndex * 7 + dayIndex));
              
              // Skip if date is outside range
              if (date.isBefore(start) || date.isAfter(end)) {
                return const SizedBox(width: 14, height: 14);
              }
              
              final volume = workoutData[_normalizeDate(date)] ?? 0.0;
              final intensity = _calculateIntensity(volume);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: GestureDetector(
                  onTap: () => onDayTap?.call(date),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(intensity),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF505050),
          ),
        ),
        const SizedBox(width: 6),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForIntensity(index),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 6),
        const Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF505050),
          ),
        ),
      ],
    );
  }

  /// Normalize date to remove time component for map lookup
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculate intensity level (0-4) based on workout volume
  int _calculateIntensity(double volume) {
    if (volume == 0) return 0;
    if (volume < 1000) return 1;   // Light workout
    if (volume < 3000) return 2;   // Moderate workout
    if (volume < 5000) return 3;   // Heavy workout
    return 4;                       // Extreme workout
  }

  /// Get color based on intensity level (GitHub-style with Noir theme)
  Color _getColorForIntensity(int intensity) {
    switch (intensity) {
      case 0:
        return const Color(0xFF2C2C2C); // Inactive: Dark Grey
      case 1:
        return const Color(0xFF4D1F1F); // Level 1: Dark Red
      case 2:
        return const Color(0xFF8B2E2E); // Level 2: Medium Red
      case 3:
        return const Color(0xFFCC3333); // Level 3: Bright Red
      case 4:
        return const Color(0xFFFF0033); // Level 4: Neon Red
      default:
        return const Color(0xFF2C2C2C);
    }
  }
}

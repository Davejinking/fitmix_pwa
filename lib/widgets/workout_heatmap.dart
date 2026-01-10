import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GitHub-style Contribution Heatmap for Workout Tracking
/// Industrial/Noir aesthetic with intensity-based color scaling
class WorkoutHeatmap extends StatefulWidget {
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
  State<WorkoutHeatmap> createState() => _WorkoutHeatmapState();
}

class _WorkoutHeatmapState extends State<WorkoutHeatmap> {
  DateTime? _selectedDate;
  double? _selectedVolume;

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - widget.monthsToShow, endDate.day);
    
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
          // Selected date info
          if (_selectedDate != null) _buildSelectedDateInfo(),
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
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(weeks, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Column(
            children: List.generate(7, (dayIndex) {
              final date = startMonday.add(Duration(days: weekIndex * 7 + dayIndex));
              final normalizedDate = _normalizeDate(date);
              
              // Skip if date is outside range
              if (date.isBefore(start) || date.isAfter(end)) {
                return const SizedBox(width: 14, height: 14);
              }
              
              final volume = widget.workoutData[normalizedDate] ?? 0.0;
              final intensity = _calculateIntensity(volume);
              final isToday = normalizedDate.isAtSameMomentAs(todayNormalized);
              final isSelected = _selectedDate != null && 
                                normalizedDate.isAtSameMomentAs(_selectedDate!);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = normalizedDate;
                      _selectedVolume = volume;
                    });
                    widget.onDayTap?.call(date);
                  },
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(intensity),
                      borderRadius: BorderRadius.circular(2),
                      border: isToday
                          ? Border.all(
                              color: Colors.white,
                              width: 1.5,
                            )
                          : isSelected
                              ? Border.all(
                                  color: const Color(0xFF007AFF),
                                  width: 1.5,
                                )
                              : null,
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

  Widget _buildSelectedDateInfo() {
    if (_selectedDate == null) return const SizedBox.shrink();
    
    final dateStr = DateFormat('MMM dd, yyyy').format(_selectedDate!);
    final volumeStr = _selectedVolume! > 0
        ? '${(_selectedVolume! / 1000).toStringAsFixed(1)}t'
        : 'Rest Day';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _selectedVolume! > 0 ? Icons.fitness_center : Icons.event_busy,
            size: 14,
            color: _selectedVolume! > 0 
                ? const Color(0xFF007AFF) 
                : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _selectedVolume! > 0
                  ? const Color(0xFF007AFF).withValues(alpha: 0.2)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              volumeStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _selectedVolume! > 0
                    ? const Color(0xFF007AFF)
                    : Colors.grey[500],
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.wb_sunny_outlined,
          size: 12,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          'Less',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForIntensity(index),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFF1C1C1E),
                  width: 0.5,
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.local_fire_department,
          size: 12,
          color: const Color(0xFFFF6B35),
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
        return Colors.white.withValues(alpha: 0.05); // Inactive: Subtle grey
      case 1:
        return const Color(0xFF4D1F1F); // Level 1: Dark Red
      case 2:
        return const Color(0xFF8B2E2E); // Level 2: Medium Red
      case 3:
        return const Color(0xFFCC3333); // Level 3: Bright Red
      case 4:
        return const Color(0xFFFF0033); // Level 4: Neon Red
      default:
        return Colors.white.withValues(alpha: 0.05);
    }
  }
}

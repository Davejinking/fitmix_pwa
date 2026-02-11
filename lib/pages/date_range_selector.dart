import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF1E88E5);
const Color kDarkBg = Color(0xFF0A0A0A);
const Color kModalBg = Color(0xFF0D0D0D);
const Color kDivider = Color(0xFF1F1F1F);
const Color kTextMuted = Color(0xFF64748B);

enum DateRangePreset {
  last7Days,
  last30Days,
  thisMonth,
  thisYear,
  custom,
}

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isDark ? kModalBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            _buildPresetOption(
              context: context,
              label: 'Last 7 days',
              onTap: () {
                final end = DateTime.now();
                final start = end.subtract(const Duration(days: 7));
                Navigator.pop(context, {'start': start, 'end': end});
              },
              isDark: isDark,
            ),
            _buildPresetOption(
              context: context,
              label: 'Last 30 days',
              onTap: () {
                final end = DateTime.now();
                final start = end.subtract(const Duration(days: 30));
                Navigator.pop(context, {'start': start, 'end': end});
              },
              isDark: isDark,
            ),
            _buildPresetOption(
              context: context,
              label: 'This month',
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(now.year, now.month + 1, 0);
                Navigator.pop(context, {'start': start, 'end': end});
              },
              isDark: isDark,
            ),
            _buildPresetOption(
              context: context,
              label: 'This year',
              onTap: () {
                final now = DateTime.now();
                final start = DateTime(now.year, 1, 1);
                final end = DateTime(now.year, 12, 31);
                Navigator.pop(context, {'start': start, 'end': end});
              },
              isDark: isDark,
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: kDivider,
            ),
            _buildPresetOption(
              context: context,
              label: 'Custom range',
              trailing: Icon(
                Icons.calendar_today,
                size: 18,
                color: const Color(0xFF9CA3AF),
              ),
              onTap: () async {
                Navigator.pop(context);
                final result = await showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.4),
                  builder: (context) => const CustomRangeCalendar(),
                );
                if (result != null && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
              isDark: isDark,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetOption({
    required BuildContext context,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class CustomRangeCalendar extends StatefulWidget {
  const CustomRangeCalendar({super.key});

  @override
  State<CustomRangeCalendar> createState() => _CustomRangeCalendarState();
}

class _CustomRangeCalendarState extends State<CustomRangeCalendar> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;

  void _onDayTapped(DateTime day) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new selection
        _startDate = day;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Complete selection
        if (day.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = day;
        } else {
          _endDate = day;
        }
        
        // Auto-apply and close
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            Navigator.pop(context, {
              'start': _startDate,
              'end': _endDate,
            });
          }
        });
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181818) : const Color(0xFFF9FAFB),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    'SELECT RANGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            
            // Calendar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildCalendar(isDark),
            ),
            
            // Hint text
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Select start and end date',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    final endDate = lastDayOfMonth.add(Duration(days: 6 - lastDayOfMonth.weekday % 7));
    final totalDays = endDate.difference(startDate).inDays + 1;
    
    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
            SizedBox(
              width: 36,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
            childAspectRatio: 1.0,
          ),
          itemCount: totalDays,
          itemBuilder: (context, index) {
            final cellDate = startDate.add(Duration(days: index));
            final isOutside = cellDate.month != _focusedMonth.month;
            final isStart = _startDate != null && isSameDay(cellDate, _startDate!);
            final isEnd = _endDate != null && isSameDay(cellDate, _endDate!);
            final isInRange = _startDate != null && _endDate != null &&
                cellDate.isAfter(_startDate!) && cellDate.isBefore(_endDate!);
            
            return _buildDayCell(
              cellDate,
              isOutside: isOutside,
              isStart: isStart,
              isEnd: isEnd,
              isInRange: isInRange,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    required bool isOutside,
    required bool isStart,
    required bool isEnd,
    required bool isInRange,
    required bool isDark,
  }) {
    final isSelected = isStart || isEnd;
    
    return GestureDetector(
      onTap: isOutside ? null : () => _onDayTapped(day),
      child: Stack(
        children: [
          // Range background
          if (isInRange || (isStart && _endDate != null) || (isEnd && _startDate != null))
            Positioned.fill(
              child: Container(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
          
          // Half backgrounds for start/end
          if (isStart && _endDate != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 18,
              child: Container(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
          if (isEnd && _startDate != null)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 18,
              child: Container(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
          
          // Day number
          Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF2B4C7E)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ) : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isOutside
                        ? const Color(0xFF374151)
                        : (isSelected 
                            ? Colors.white
                            : (isInRange 
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFF9CA3AF))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../l10n/app_localizations.dart';

class WeekStrip extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final void Function(DateTime) onWeekChanged;
  final Set<String> workoutDates; // 운동한 날짜들 (yyyy-MM-dd 형식)
  final Set<String> restDates; // 휴식 날짜들 (yyyy-MM-dd 형식)

  const WeekStrip({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onWeekChanged,
    this.workoutDates = const {},
    this.restDates = const {},
  });

  void _goToPreviousWeek() {
    final previousWeek = focusedDay.subtract(const Duration(days: 7));
    onWeekChanged(previousWeek);
  }

  void _goToNextWeek() {
    final nextWeek = focusedDay.add(const Duration(days: 7));
    onWeekChanged(nextWeek);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 현재 주의 시작일 (월요일)
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // Pure Black background
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 이전 주 버튼 (Simple, no background)
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: _goToPreviousWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: const Color(0xFFFFFFFF),
          ),
          // 7일 버튼
          ...weekDays.map((day) {
            final isSelected = isSameDay(day, selectedDay);
            final isToday = isSameDay(day, DateTime.now());
            final dayYmd = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final hasWorkout = workoutDates.contains(dayYmd);
            final isRest = restDates.contains(dayYmd);
            final weekdays = [
              l10n.weekdayMon,
              l10n.weekdayTue,
              l10n.weekdayWed,
              l10n.weekdayThu,
              l10n.weekdayFri,
              l10n.weekdaySat,
              l10n.weekdaySun,
            ];
            final weekdayIndex = day.weekday - 1;

            return Expanded(
              child: InkWell(
                onTap: () => onDaySelected(day),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    // Selected: Sharp underline (Terminal cursor style)
                    border: isSelected
                        ? const Border(
                            bottom: BorderSide(
                              color: Color(0xFF007AFF), // Accent Blue
                              width: 3,
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Weekday label (Small, Low contrast)
                      Text(
                        weekdays[weekdayIndex],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF505050), // Dark Grey
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date number (Large, High contrast)
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFFFFF) // Selected: White
                              : isToday
                                  ? const Color(0xFF007AFF) // Today: Accent Blue
                                  : const Color(0xFFFFFFFF), // Default: White
                          fontFamily: 'Courier', // Monospace for terminal feel
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Workout indicator (Minimal dot)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: hasWorkout
                              ? const Color(0xFF007AFF) // Blue dot for workout
                              : isRest
                                  ? const Color(0xFFFF6B35) // Orange dot for rest
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // 다음 주 버튼 (Simple, no background)
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            onPressed: _goToNextWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: const Color(0xFFFFFFFF),
          ),
        ],
      ),
    );
  }
}

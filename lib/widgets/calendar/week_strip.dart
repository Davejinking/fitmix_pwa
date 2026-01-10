import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
    final locale = Localizations.localeOf(context);
    
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Dark background
        border: Border.all(
          color: const Color(0xFF2C2C2E),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Custom Header Row (Control Panel Style)
          _buildCustomHeader(context, locale),
          const SizedBox(height: 16),
          // Week Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
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
                      // Selected: Solid Rounded Rectangle (Control Panel Button)
                      color: isSelected
                          ? const Color(0xFF2962FF) // Electric Blue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      // Today: Subtle border if not selected
                      border: !isSelected && isToday
                          ? Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Weekday label (Small, Low contrast)
                        Text(
                          weekdays[weekdayIndex],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[600], // Grey for default
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
                                ? Colors.white // Selected: White, Bold
                                : isToday
                                    ? const Color(0xFF2962FF) // Today: Electric Blue
                                    : Colors.grey[600], // Default: Grey
                            fontFamily: 'Courier', // Monospace for Control Panel feel
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Workout indicator (Minimal dot)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: hasWorkout
                                ? const Color(0xFF2962FF) // Blue dot for workout
                                : isRest
                                    ? const Color(0xFFD50000) // Red dot for rest
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, Locale locale) {
    // Format month/year based on locale
    final monthFormat = locale.languageCode == 'ja'
        ? DateFormat('yyyy年M月', locale.toString())
        : locale.languageCode == 'ko'
            ? DateFormat('yyyy년 M월', locale.toString())
            : DateFormat('MMM yyyy', locale.toString());
    
    final monthYear = monthFormat.format(focusedDay).toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Week Button
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          onPressed: _goToPreviousWeek,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: Colors.white,
        ),
        // Month/Year Title (Bold, Monospaced)
        Text(
          monthYear,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Courier', // Monospace for Control Panel
            letterSpacing: 1.5,
          ),
        ),
        // Next Week Button
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 24),
          onPressed: _goToNextWeek,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          color: Colors.white,
        ),
      ],
    );
  }
}

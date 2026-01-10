import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Date Control Module - Industrial/Noir style weekly calendar
/// Matches the Exercise Card design aesthetic
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
    
    // Format month/year based on locale
    final monthFormat = locale.languageCode == 'ja'
        ? DateFormat('yyyy年M月', locale.toString())
        : locale.languageCode == 'ko'
            ? DateFormat('yyyy년 M월', locale.toString())
            : DateFormat('MMM yyyy', locale.toString());
    
    final monthYear = monthFormat.format(focusedDay).toUpperCase();
    
    // 현재 주의 시작일 (월요일)
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month/Year Label (Outside the module)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              monthYear,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
          ),
          
          // Date Control Module Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Matches Exercise Card
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1), // Subtle border
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12), // Rounded module
            ),
            child: Row(
              children: [
                // Previous Week Button
                _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onPressed: _goToPreviousWeek,
                ),
                
                // Week Days
                Expanded(
                  child: Row(
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

                      return _buildDayCell(
                        day: day,
                        weekdayLabel: weekdays[weekdayIndex],
                        isSelected: isSelected,
                        isToday: isToday,
                        hasWorkout: hasWorkout,
                        isRest: isRest,
                      );
                    }).toList(),
                  ),
                ),
                
                // Next Week Button
                _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onPressed: _goToNextWeek,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        color: Colors.grey[600],
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required String weekdayLabel,
    required bool isSelected,
    required bool isToday,
    required bool hasWorkout,
    required bool isRest,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onDaySelected(day),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            // Selected: Rounded Rectangle with Electric Blue
            color: isSelected
                ? const Color(0xFF2962FF) // Electric Blue (matches BEST badge)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            // Today: Border if not selected
            border: !isSelected && isToday
                ? Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weekday label (MON, TUE...)
              Text(
                weekdayLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Date number (Monospaced for digital look)
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? Colors.blueAccent
                          : Colors.white,
                  fontFamily: 'Courier', // Monospaced font
                ),
              ),
              const SizedBox(height: 6),
              // Activity indicator dot
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? const Color(0xFF2962FF) // Blue for workout
                      : isRest
                          ? const Color(0xFFFF6B35) // Orange for rest
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

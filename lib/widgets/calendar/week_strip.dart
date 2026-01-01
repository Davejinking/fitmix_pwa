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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 이전 주 버튼
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              onPressed: _goToPreviousWeek,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              color: const Color(0xFFFFFFFF),
            ),
          ),
          // 7일 버튼
          ...weekDays.map((day) {
            final isSelected = isSameDay(day, selectedDay);
            final isToday = isSameDay(day, DateTime.now());
            final dayYmd = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final hasWorkout = workoutDates.contains(dayYmd);
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
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(
                            color: const Color(0xFF007AFF),
                            width: 1.5,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekdays[weekdayIndex],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 운동 기록 점 표시 (파란색) 또는 휴식 점 표시 (빨간색)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: hasWorkout
                              ? const Color(0xFF007AFF)
                              : restDates.contains(dayYmd)
                                  ? Colors.red
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
          // 다음 주 버튼
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              onPressed: _goToNextWeek,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

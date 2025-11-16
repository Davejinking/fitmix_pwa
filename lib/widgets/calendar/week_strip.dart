import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/burn_fit_style.dart';
import '../../l10n/app_localizations.dart';

class WeekStrip extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final void Function(DateTime) onWeekChanged;

  const WeekStrip({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onWeekChanged,
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
    final l10n = AppLocalizations.of(context)!;
    
    // 현재 주의 시작일 (월요일)
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday - 1),
    );
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 이전 주 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _goToPreviousWeek,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: BurnFitStyle.darkGrayText,
            ),
          ),
          // 7일 버튼
          ...weekDays.map((day) {
            final isSelected = isSameDay(day, selectedDay);
            final isToday = isSameDay(day, DateTime.now());
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
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BurnFitStyle.primaryBlue
                        : Colors.transparent,
                    border: isToday && !isSelected
                        ? Border.all(
                            color: BurnFitStyle.primaryBlue,
                            width: 1.5,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekdays[weekdayIndex],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : BurnFitStyle.secondaryGrayText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : BurnFitStyle.darkGrayText,
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
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _goToNextWeek,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: BurnFitStyle.darkGrayText,
            ),
          ),
        ],
      ),
    );
  }
}

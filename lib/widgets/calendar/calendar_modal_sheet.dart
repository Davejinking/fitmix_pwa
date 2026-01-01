import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/burn_fit_style.dart';
import '../../data/session_repo.dart';
import '../../data/exercise_library_repo.dart';
import '../../pages/plan_page.dart';
import '../../l10n/app_localizations.dart';

class CalendarModalSheet extends StatefulWidget {
  final DateTime initialDate;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const CalendarModalSheet({
    super.key,
    required this.initialDate,
    required this.repo,
    required this.exerciseRepo,
  });

  @override
  State<CalendarModalSheet> createState() => _CalendarModalSheetState();
}

class _CalendarModalSheetState extends State<CalendarModalSheet> {
  late DateTime _tempSelectedDate;
  late DateTime _focusedMonth;
  late PageController _pageController;
  static const int _initialPage = 500;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.initialDate;
    _focusedMonth = widget.initialDate;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(
      widget.initialDate.year,
      widget.initialDate.month + offset,
    );
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // 타이틀
            Text(
              AppLocalizations.of(context).selectDate,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BurnFitStyle.darkGrayText,
              ),
            ),
            const SizedBox(height: 16),
            // 월 네비게이션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_focusedMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: BurnFitStyle.darkGrayText,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: BurnFitStyle.primaryBlue,
                        ),
                        onPressed: _goToPreviousMonth,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: BurnFitStyle.primaryBlue,
                        ),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 캘린더 (PageView)
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _focusedMonth = _getMonthForPage(page);
                  });
                },
                itemBuilder: (context, index) {
                  final monthDate = _getMonthForPage(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TableCalendar(
                      locale: Localizations.localeOf(context).toString(),
                      focusedDay: monthDate,
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      headerVisible: false,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      selectedDayPredicate: (day) =>
                          isSameDay(_tempSelectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _tempSelectedDate = selectedDay;
                        });
                      },
                      daysOfWeekHeight: 40,
                      rowHeight: 48,
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(4),
                        // 오늘
                        todayDecoration: BoxDecoration(
                          border: Border.all(
                            color: BurnFitStyle.primaryBlue.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: BurnFitStyle.darkGrayText,
                          fontWeight: FontWeight.w600,
                        ),
                        // 선택된 날짜
                        selectedDecoration: BoxDecoration(
                          color: BurnFitStyle.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        // 기본
                        defaultTextStyle: TextStyle(
                          color: BurnFitStyle.darkGrayText,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        // 주말
                        weekendTextStyle: TextStyle(
                          color: BurnFitStyle.darkGrayText,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        // 다른 달
                        outsideTextStyle: TextStyle(
                          color: Colors.grey[350],
                          fontSize: 15,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final l10n = AppLocalizations.of(context);
                          final weekdays = [
                            l10n.weekdaySun,
                            l10n.weekdayMon,
                            l10n.weekdayTue,
                            l10n.weekdayWed,
                            l10n.weekdayThu,
                            l10n.weekdayFri,
                            l10n.weekdaySat,
                          ];
                          final text = weekdays[day.weekday % 7];
                          return Center(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: BurnFitStyle.secondaryGrayText,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // 운동 계획하기 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlanPage(
                          date: _tempSelectedDate,
                          repo: widget.repo,
                          exerciseRepo: widget.exerciseRepo,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurnFitStyle.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).planWorkout,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

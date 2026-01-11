import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

/// Date Control Module - Industrial/Noir style expandable calendar
/// Matches the Exercise Card design aesthetic with week/month toggle
class WeekStrip extends StatefulWidget {
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

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDay != oldWidget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.week
          ? CalendarFormat.month
          : CalendarFormat.week;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    widget.onDaySelected(selectedDay);
    
    // Auto-collapse to week view when a day is selected in month view
    if (_calendarFormat == CalendarFormat.month) {
      setState(() {
        _calendarFormat = CalendarFormat.week;
        _focusedDay = selectedDay;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    widget.onWeekChanged(focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    // Format month/year based on locale
    final monthFormat = locale.languageCode == 'ja'
        ? DateFormat('yyyy年M月', locale.toString())
        : locale.languageCode == 'ko'
            ? DateFormat('yyyy년 M월', locale.toString())
            : DateFormat('MMM yyyy', locale.toString());
    
    final monthYear = monthFormat.format(_focusedDay).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expandable Header (Tap to toggle week/month)
          InkWell(
            onTap: _toggleCalendarFormat,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthYear,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                      fontFamily: 'Courier',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _calendarFormat == CalendarFormat.week
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Date Control Module Container with TableCalendar
          // Pure black background - no card effect
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, widget.selectedDay),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                
                // Hide default header (we have custom header above)
                headerVisible: false,
                
                // Callbacks
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                
                // Styling - Iron Calendar Design
                calendarStyle: CalendarStyle(
                  // Cell decoration with grid lines
                  cellMargin: const EdgeInsets.all(0),
                  cellPadding: EdgeInsets.zero, // 핵심: 기본 패딩 제거
                  
                  // Disable default decorations (we use builders instead)
                  todayDecoration: const BoxDecoration(),
                  selectedDecoration: const BoxDecoration(),
                  defaultDecoration: const BoxDecoration(),
                  weekendDecoration: const BoxDecoration(),
                  outsideDecoration: const BoxDecoration(),
                  
                  // Text styles (fallback only, builders override these)
                  defaultTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                  
                  // Markers
                  markerDecoration: const BoxDecoration(
                    color: Colors.white, // White - High-End Monochrome
                    shape: BoxShape.rectangle, // Square marker
                  ),
                  markerSize: 3,
                  markersMaxCount: 1,
                ),
                
                // Days of week style
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                
                // Event loader for markers
                eventLoader: (day) {
                  final dayYmd = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  if (widget.workoutDates.contains(dayYmd)) {
                    return ['workout'];
                  } else if (widget.restDates.contains(dayYmd)) {
                    return ['rest'];
                  }
                  return [];
                },
                
                // Custom builders for markers
                calendarBuilders: CalendarBuilders(
                  // 1. [평일] 투명 박스 적용 -> 높이 강제 동기화
                  defaultBuilder: (context, date, events) {
                    return Container(
                      alignment: Alignment.topCenter, // 천장에 매달기
                      padding: const EdgeInsets.only(top: 8.0), // 천장에서 8px 띄움
                      child: Container(
                        width: 28,
                        height: 28, // 박스 크기 고정
                        alignment: Alignment.center, // 박스 안에서 글자 중앙
                        decoration: const BoxDecoration(
                          color: Colors.transparent, // 투명 (안 보임)
                          shape: BoxShape.rectangle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                  
                  // 2. [오늘] 하얀 박스
                  todayBuilder: (context, date, events) {
                    return Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 8.0), // 동일한 패딩
                      child: Container(
                        width: 28,
                        height: 28, // 동일한 크기
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white, // 하얀 배경
                          borderRadius: BorderRadius.circular(4.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.black, // 반전 글씨
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    );
                  },
                  
                  // 3. [선택됨] 하얀 테두리
                  selectedBuilder: (context, date, events) {
                    return Container(
                      alignment: Alignment.topCenter, // 핵심: 상단 정렬 강제
                      padding: const EdgeInsets.only(top: 8.0), // 동일한 패딩
                      child: Container(
                        width: 28,
                        height: 28, // 동일한 크기
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2.0), // 테두리만
                          borderRadius: BorderRadius.circular(4.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    );
                  },
                  
                  // 4. [마커] 둥근 사각형 점
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox();
                    
                    final dayYmd = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                    final hasWorkout = widget.workoutDates.contains(dayYmd);
                    final isRest = widget.restDates.contains(dayYmd);
                    
                    return Positioned(
                      bottom: 6, // 바닥 고정
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: hasWorkout ? Colors.white : Colors.transparent,
                          border: isRest ? Border.all(color: Colors.white, width: 1.0) : null,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Hard line separator below calendar
              Divider(
                color: Colors.grey[800],
                height: 1,
                thickness: 1,
              ),
              // Breathing space between calendar and stats
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Matches Exercise Card
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1), // Subtle border
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12), // Rounded module
            ),
            child: TableCalendar(
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
              
              // Styling
              calendarStyle: CalendarStyle(
                // Today style
                todayDecoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                
                // Selected day style
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF2962FF), // Electric Blue
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                
                // Default day style
                defaultDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                
                // Weekend style
                weekendDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                weekendTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                
                // Outside month style
                outsideDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                
                // Markers
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF2962FF),
                  shape: BoxShape.circle,
                ),
                markerSize: 4,
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
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  
                  final dayYmd = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  final hasWorkout = widget.workoutDates.contains(dayYmd);
                  final isRest = widget.restDates.contains(dayYmd);
                  
                  return Positioned(
                    bottom: 4,
                    child: Container(
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

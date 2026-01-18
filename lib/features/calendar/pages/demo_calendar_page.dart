import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// R&D Lab: Shape & Format Testing
/// Tests Circle vs Square vs Rounded Square markers
enum MarkerShape { circle, square, roundedSquare }

class DemoCalendarPage extends StatefulWidget {
  const DemoCalendarPage({super.key});

  @override
  State<DemoCalendarPage> createState() => _DemoCalendarPageState();
}

class _DemoCalendarPageState extends State<DemoCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  MarkerShape _markerShape = MarkerShape.roundedSquare; // Recommended default
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // FAKE DATA for Simulation
  final Map<DateTime, String> _dummyEvents = {};

  @override
  void initState() {
    super.initState();
    _generateDummyData();
  }

  void _generateDummyData() {
    final now = DateTime.now();
    // Create events for the past 2 weeks
    for (int i = 0; i < 14; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      if (i % 3 == 0) {
        _dummyEvents[date] = 'Workout'; // Solid Square
      } else if (i % 5 == 0) {
        _dummyEvents[date] = 'Rest'; // Hollow Square
      }
    }
    // Today is always a workout
    _dummyEvents[DateTime(now.year, now.month, now.day)] = 'Workout';
  }

  String? _getEventForDay(DateTime day) {
    final key = _dummyEvents.keys.firstWhere(
      (k) => isSameDay(k, day),
      orElse: () => DateTime(1900),
    );
    if (key.year == 1900) return null;
    return _dummyEvents[key];
  }

  // Get marker decoration based on current shape
  BoxDecoration _getMarkerDecoration({required bool isRest}) {
    BoxShape boxShape;
    BorderRadius? radius;

    switch (_markerShape) {
      case MarkerShape.circle:
        boxShape = BoxShape.circle;
        radius = null;
        break;
      case MarkerShape.square:
        boxShape = BoxShape.rectangle;
        radius = BorderRadius.zero;
        break;
      case MarkerShape.roundedSquare:
        boxShape = BoxShape.rectangle;
        radius = BorderRadius.circular(2.0);
        break;
    }

    return BoxDecoration(
      color: isRest ? Colors.transparent : Colors.white,
      border: isRest ? Border.all(color: Colors.white, width: 1) : null,
      shape: boxShape,
      borderRadius: boxShape == BoxShape.rectangle ? radius : null,
    );
  }

  String _getShapeLabel() {
    switch (_markerShape) {
      case MarkerShape.circle:
        return 'CIRCLE';
      case MarkerShape.square:
        return 'SQUARE';
      case MarkerShape.roundedSquare:
        return 'ROUNDED';
    }
  }

  void _cycleShape() {
    setState(() {
      switch (_markerShape) {
        case MarkerShape.circle:
          _markerShape = MarkerShape.square;
          break;
        case MarkerShape.square:
          _markerShape = MarkerShape.roundedSquare;
          break;
        case MarkerShape.roundedSquare:
          _markerShape = MarkerShape.circle;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // The Void
      appBar: AppBar(
        title: const Text(
          'SHAPE LAB',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontFamily: 'Courier',
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Shape Toggle Button
          TextButton(
            onPressed: _cycleShape,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _markerShape == MarkerShape.circle
                      ? Icons.circle_outlined
                      : Icons.crop_square,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getShapeLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Format Toggle Button
          TextButton(
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
            child: Text(
              _calendarFormat == CalendarFormat.week ? 'EXPAND' : 'COLLAPSE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Info Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEGEND',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[600],
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: _getMarkerDecoration(isRest: false),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Workout Day (Solid)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: _getMarkerDecoration(isRest: true),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rest Day (Hollow)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // THE NEW CALENDAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              
              // Format Control
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.week: 'Week',
                CalendarFormat.month: 'Month',
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              
              // 1. Header Style
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  letterSpacing: 1.5,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
              
              // 2. Calendar Body Style
              calendarStyle: CalendarStyle(
                // Default days
                defaultTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
                outsideTextStyle: TextStyle(
                  color: Colors.grey[900],
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
                
                // Hide outside days for cleaner look
                outsideDaysVisible: false,
                
                // Selected: Sharp White Border
                selectedDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2.0),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.zero,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
                
                // Today: Text Highlight only
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
                
                // Cell decoration
                defaultDecoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0A0A0A),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.zero,
                ),
                weekendDecoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0A0A0A),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.zero,
                ),
                outsideDecoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0A0A0A),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              
              // 3. Days of week style
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                ),
                weekendStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                ),
              ),
              
              // 4. DYNAMIC SHAPE MARKERS
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final event = _getEventForDay(day);
                  if (event == null) return const SizedBox();
                  
                  final isRest = event == 'Rest';
                  
                  return Positioned(
                    bottom: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: _getMarkerDecoration(isRest: isRest),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const Spacer(),
          
          // Status Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SHAPE: ${_getShapeLabel()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'FORMAT: ${_calendarFormat.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // THE GHOST BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Selected day info
                if (_selectedDay != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SELECTED: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Courier',
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_getEventForDay(_selectedDay!) != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              _getEventForDay(_selectedDay!)!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Ghost button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'SHAPE: ${_getShapeLabel()} | FORMAT: ${_calendarFormat.name.toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              letterSpacing: 1.0,
                              color: Colors.black,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'APPLY CURRENT SETTINGS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

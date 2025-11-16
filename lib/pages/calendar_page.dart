import 'package:flutter/material.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../widgets/calendar/month_header.dart';
import '../widgets/calendar/week_strip.dart';
import '../widgets/calendar/day_timeline_list.dart';

class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const CalendarPage({super.key, required this.repo, required this.exerciseRepo});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 상태 관리 (단순화)
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // 데이터
  List<Session> _workoutSessions = [];
  late final ValueNotifier<List<Session>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _loadWorkoutSessions();
  }

  Future<void> _loadWorkoutSessions() async {
    final sessions = await widget.repo.getWorkoutSessions();
    if (mounted) {
      setState(() {
        _workoutSessions = sessions;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    }
  }

  List<Session> _getEventsForDay(DateTime day) {
    final ymd = widget.repo.ymd(day);
    return _workoutSessions.where((session) => session.ymd == ymd).toList();
  }

  void _onDaySelected(DateTime selectedDay) {
    if (mounted) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // 월 헤더
              MonthHeader(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDateSelected: (date) {
                  _onDaySelected(date);
                },
                repo: widget.repo,
                exerciseRepo: widget.exerciseRepo,
              ),
              // 주간 스트립
              WeekStrip(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
                onWeekChanged: (newWeekStart) {
                  setState(() {
                    _focusedDay = newWeekStart;
                    _selectedDay = newWeekStart;
                  });
                  _selectedEvents.value = _getEventsForDay(_selectedDay);
                },
              ),
              // 타임라인 리스트
              Expanded(
                child: DayTimelineList(
                  selectedDay: _selectedDay,
                  selectedEvents: _selectedEvents,
                  repo: widget.repo,
                  exerciseRepo: widget.exerciseRepo,
                  topPadding: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/burn_fit_style.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import 'plan_page.dart';

class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const CalendarPage({super.key, required this.repo, required this.exerciseRepo});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Session>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  late final PageController _pageController;
  DateTime? _selectedDay;
  List<Session> _workoutSessions = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadWorkoutSessions();
  }

  Future<void> _loadWorkoutSessions() async {
    final sessions = await widget.repo.getWorkoutSessions();
    setState(() {
      _workoutSessions = sessions;
    });
  }

  List<Session> _getEventsForDay(DateTime day) {
    final ymd = widget.repo.ymd(day);
    return _workoutSessions.where((session) => session.ymd == ymd).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      // PlanPage에서 돌아왔을 때 캘린더가 업데이트되도록,
      // 운동 목록을 다시 로드하고 이벤트를 갱신합니다.
      await _loadWorkoutSessions();
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurnFitStyle.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderComponent(
              focusedDay: _focusedDay,
              onLeftArrowTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              onRightArrowTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
            _BodyComponent(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              getEventsForDay: _getEventsForDay,
              onDaySelected: _onDaySelected,
              onCalendarCreated: (pageController) => _pageController = pageController,
              onPageChanged: (focusedDay) => setState(() {
                setState(() {
                  _focusedDay = focusedDay;
                });
              }),
            ),
            _SelectedDateDetailView(
              selectedDay: _selectedDay!,
              repo: widget.repo,
              exerciseRepo: widget.exerciseRepo,
              selectedEvents: _selectedEvents,
            ),
          ],
        ),
      ),
    );
  }
}

// 3.1 HeaderComponent
class _HeaderComponent extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;

  const _HeaderComponent({
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(DateFormat('yyyy년 MM월').format(focusedDay), style: BurnFitStyle.title1),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: onLeftArrowTap),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: onRightArrowTap),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_view_month, color: BurnFitStyle.darkGrayText),
            onPressed: () { /* TODO: 보기 형식 전환 */ },
          ),
        ],
      ),
    );
  }
}

// 3.2 BodyComponent
class _BodyComponent extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<Session> Function(DateTime) getEventsForDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(PageController) onCalendarCreated;
  final void Function(DateTime) onPageChanged;

  const _BodyComponent({
    required this.focusedDay,
    required this.selectedDay,
    required this.getEventsForDay,
    required this.onDaySelected,
    required this.onCalendarCreated,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // FilterButton
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () { /* TODO: 필터 옵션 */ },
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('필터'),
                  style: TextButton.styleFrom(
                    foregroundColor: BurnFitStyle.darkGrayText,
                    backgroundColor: BurnFitStyle.lightGray,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              // CalendarView
              TableCalendar<Session>(
                locale: 'ko_KR',
                focusedDay: focusedDay,
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                headerVisible: false,
                startingDayOfWeek: StartingDayOfWeek.monday, // 1. 주 시작을 월요일로 변경
                eventLoader: getEventsForDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: onDaySelected,
                // 2, 3. 월 이동을 위한 컨트롤러 및 콜백
                onCalendarCreated: onCalendarCreated,
                onPageChanged: onPageChanged,
                calendarStyle: CalendarStyle(
                  // isToday
                  todayDecoration: const BoxDecoration(
                    color: BurnFitStyle.mediumGray,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: BurnFitStyle.darkGrayText),
                  // isSelected
                  selectedDecoration: const BoxDecoration(
                    color: BurnFitStyle.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: BurnFitStyle.white),
                  // isOtherMonth
                  outsideTextStyle: const TextStyle(color: BurnFitStyle.mediumGray),
                  // hasEvent
                  markerDecoration: const BoxDecoration(
                    color: BurnFitStyle.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  // DayOfWeekHeader
                  dowBuilder: (context, day) {
                    final text = DateFormat.E('ko_KR').format(day);
                    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                    return Center(
                      child: Text(
                        text,
                        style: BurnFitStyle.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isWeekend ? BurnFitStyle.primaryBlue : BurnFitStyle.secondaryGrayText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SelectedDateDetailView
class _SelectedDateDetailView extends StatelessWidget {
  final DateTime selectedDay;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final ValueNotifier<List<Session>> selectedEvents;

  const _SelectedDateDetailView({
    required this.selectedDay,
    required this.repo,
    required this.exerciseRepo,
    required this.selectedEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DateFormat('M월 d일 E', 'ko_KR').format(selectedDay),
            style: BurnFitStyle.title2,
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<Session>>(
            valueListenable: selectedEvents,
            builder: (context, sessions, _) {
              if (sessions.isEmpty || !sessions.first.isWorkoutDay) {
                // 운동 기록이 없으면 '운동 계획하기' 버튼 표시
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        PlanPage(date: selectedDay, repo: repo, exerciseRepo: exerciseRepo)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurnFitStyle.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('운동 계획하기', style: BurnFitStyle.body.copyWith(color: BurnFitStyle.white, fontWeight: FontWeight.bold)),
                );
              } else {
                // 운동 기록이 있으면 목록 표시
                return _WorkoutListView(session: sessions.first, repo: repo, exerciseRepo: exerciseRepo);
              }
            },
          ),
          const SizedBox(height: 24),
          // AdvertisementCard
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: BurnFitStyle.mediumGray),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('광고 영역')), // 임시 광고 카드
          ),
        ],
      ),
    );
  }
}

class _WorkoutListView extends StatelessWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  const _WorkoutListView({required this.session, required this.repo, required this.exerciseRepo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BurnFitStyle.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final exercise in session.exercises)
            Text('• ${exercise.bodyPart} - ${exercise.name}', style: BurnFitStyle.body),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => PlanPage(
                            date: repo.ymdToDateTime(session.ymd), repo: repo, exerciseRepo: exerciseRepo)))
                    .then((_) {
                  // PlanPage에서 돌아오면 캘린더를 새로고침하기 위해 이벤트를 다시 발생시킴
                  (context as Element).findAncestorStateOfType<_CalendarPageState>()?._onDaySelected(
                      repo.ymdToDateTime(session.ymd), repo.ymdToDateTime(session.ymd));
                });
              },
              child: const Text('수정하기'),
            ),
          ),
        ],
      ),
    );
  }
}

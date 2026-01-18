import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../features/calendar/pages/plan_page.dart';
import 'calendar_modal_sheet.dart';

class MonthHeader extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime) onDateSelected;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final Set<String> workoutDates; // 운동한 날짜들
  final Set<String> restDates; // 휴식 날짜들
  final Future<void> Function()? onRestStatusChanged; // 휴식 상태 변경 콜백

  const MonthHeader({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDateSelected,
    required this.repo,
    required this.exerciseRepo,
    required this.workoutDates,
    required this.restDates,
    this.onRestStatusChanged,
  });

  Future<void> _showCalendarModal(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarModalSheet(
        initialDate: selectedDay,
        repo: repo,
        exerciseRepo: exerciseRepo,
        workoutDates: workoutDates,
        restDates: restDates,
      ),
    );
    
    // 휴식 상태가 변경되었으면 부모에 알림
    if (result == true) {
      await onRestStatusChanged?.call();
    }
  }

  void _goToToday() {
    final today = DateTime.now();
    onDateSelected(today);
  }

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDay.year == DateTime.now().year &&
        selectedDay.month == DateTime.now().month &&
        selectedDay.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜 선택기 (깔끔한 텍스트 스타일)
          InkWell(
            onTap: () => _showCalendarModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(focusedDay),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // 아이콘들
          Row(
            children: [
              // 오늘 버튼 (캘린더 아이콘)
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  size: 22,
                  color: isToday ? const Color(0xFF007AFF) : Colors.white,
                ),
                onPressed: _goToToday,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              // 루틴 추가 버튼
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlanPage(
                        date: selectedDay,
                        repo: repo,
                        exerciseRepo: exerciseRepo,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

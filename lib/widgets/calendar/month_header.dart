import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../pages/plan_page.dart';
import 'calendar_modal_sheet.dart';

class MonthHeader extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime) onDateSelected;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const MonthHeader({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDateSelected,
    required this.repo,
    required this.exerciseRepo,
  });

  Future<void> _showCalendarModal(BuildContext context) async {
    await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarModalSheet(
        initialDate: selectedDay,
        repo: repo,
        exerciseRepo: exerciseRepo,
      ),
    );
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
                    DateFormat.yMMMM('ko').format(focusedDay),
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

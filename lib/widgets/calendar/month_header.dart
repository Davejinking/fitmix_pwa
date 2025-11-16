import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/burn_fit_style.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 월 선택 버튼
          InkWell(
            onTap: () => _showCalendarModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMM().format(focusedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BurnFitStyle.darkGrayText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: BurnFitStyle.darkGrayText,
                  ),
                ],
              ),
            ),
          ),
          // 아이콘들
          Row(
            children: [
              // 오늘 버튼 (오늘 선택 시 강조)
              Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? BurnFitStyle.primaryBlue.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(
                          color: BurnFitStyle.primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: IconButton(
                  icon: const Icon(Icons.today, size: 20),
                  onPressed: _goToToday,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  color: isToday ? BurnFitStyle.primaryBlue : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: BurnFitStyle.primaryBlue,
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
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey[600],
                  size: 24,
                ),
                onPressed: () {}, // TODO: 필터 기능
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

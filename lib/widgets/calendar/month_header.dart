import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../data/settings_repo.dart';
import '../../pages/plan_page.dart';
import 'calendar_modal_sheet.dart';

class MonthHeader extends StatelessWidget {
  final DateTime focusedDate; // focusedDay -> focusedDate
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTitleTap;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo? settingsRepo;

  const MonthHeader({
    super.key,
    required this.focusedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTitleTap,
    required this.repo,
    required this.exerciseRepo,
    this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(focusedDate),
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
                        date: focusedDate,
                        repo: repo,
                        exerciseRepo: exerciseRepo,
                        settingsRepo: settingsRepo,
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

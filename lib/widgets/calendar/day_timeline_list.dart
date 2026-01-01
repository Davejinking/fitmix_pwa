import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../data/settings_repo.dart';
import '../../models/session.dart';
import '../../pages/plan_page.dart';
import '../../l10n/app_localizations.dart';

class DayTimelineList extends StatelessWidget {
  final DateTime monthDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo? settingsRepo;

  const DayTimelineList({
    super.key,
    required this.monthDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.repo,
    required this.exerciseRepo,
    this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    // 해당 월의 모든 날짜 생성
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final dates = List.generate(
      daysInMonth,
      (index) => DateTime(monthDate.year, monthDate.month, index + 1),
    );

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected = isSameDay(date, selectedDate);
        final isToday = isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF007AFF), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.E(Localizations.localeOf(context).languageCode).format(date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
                // 운동 완료 마커 (여기서는 간단하게 표시, 실제 데이터 연동 필요)
                // FutureBuilder 등을 사용하여 해당 날짜의 운동 여부 확인 가능
                FutureBuilder<Session?>(
                  future: repo.get(repo.ymd(date)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isWorkoutDay) {
                        return Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : const Color(0xFF007AFF),
                          ),
                        );
                    }
                    return const SizedBox(height: 10);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WorkoutSessionCard extends StatelessWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo? settingsRepo;

  const _WorkoutSessionCard({
    required this.session,
    required this.repo,
    required this.exerciseRepo,
    this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF007AFF),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.workoutRecord,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      Text(
                        l10n.totalVolume(session.totalVolume.toStringAsFixed(0)),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 22, color: Color(0xFF007AFF)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlanPage(
                        date: repo.ymdToDateTime(session.ymd),
                        repo: repo,
                        exerciseRepo: exerciseRepo,
                        settingsRepo: settingsRepo,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFF2C2C2E)),
          const SizedBox(height: 16),
          // 운동 목록
          ...session.exercises.map((exercise) {
            // 세트 정보 요약 (예: 4세트, 최고 80kg x 6회)
            final setCount = exercise.sets.length;
            final maxWeightSet = exercise.sets.reduce((a, b) => 
              a.weight > b.weight ? a : b
            );
            final setInfo = '$setCount세트 • 최고 ${maxWeightSet.weight.toStringAsFixed(0)}kg × ${maxWeightSet.reps}회';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          setInfo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

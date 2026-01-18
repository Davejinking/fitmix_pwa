import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../models/session.dart';
import '../../features/calendar/pages/plan_page.dart';
import '../../features/workout/pages/log_detail_page.dart';
import '../../l10n/app_localizations.dart';

class DayTimelineList extends StatelessWidget {
  final DateTime selectedDay;
  final ValueNotifier<List<Session>> selectedEvents;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final double topPadding;

  const DayTimelineList({
    super.key,
    required this.selectedDay,
    required this.selectedEvents,
    required this.repo,
    required this.exerciseRepo,
    this.topPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Session>>(
      valueListenable: selectedEvents,
      builder: (context, sessions, _) {
        return Container(
          color: const Color(0xFF121212),
          child: sessions.isEmpty || !sessions.first.isWorkoutDay
              ? _buildEmptyState(context)
              : _buildSessionList(context, sessions),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center,
              size: 64,
              color: Color(0xFF2C2C2E),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat.MMMEd().format(selectedDay),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noWorkoutRecords,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
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
              icon: const Icon(Icons.add),
              label: Text(l10n.planWorkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, List<Session> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _WorkoutSessionCard(
          session: session,
          repo: repo,
          exerciseRepo: exerciseRepo,
        );
      },
    );
  }
}

class _WorkoutSessionCard extends StatelessWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const _WorkoutSessionCard({
    required this.session,
    required this.repo,
    required this.exerciseRepo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        // Open Receipt-style detail view
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LogDetailPage(
              session: session,
              repo: repo,
              exerciseRepo: exerciseRepo,
            ),
          ),
        );
      },
      child: Container(
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
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF007AFF),
                  size: 24,
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
      ),
    );
  }
}

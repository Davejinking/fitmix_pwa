import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/burn_fit_style.dart';
import '../../data/exercise_library_repo.dart';
import '../../data/session_repo.dart';
import '../../models/session.dart';
import '../../pages/plan_page.dart';
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
          color: const Color(0xFFF5F5F5),
          child: sessions.isEmpty || !sessions.first.isWorkoutDay
              ? _buildEmptyState(context)
              : _buildSessionList(context, sessions),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat.MMMEd().format(selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BurnFitStyle.darkGrayText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noWorkoutRecords,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
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
                backgroundColor: BurnFitStyle.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BurnFitStyle.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: BurnFitStyle.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.workoutRecord,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BurnFitStyle.darkGrayText,
                        ),
                      ),
                      Text(
                        l10n.totalVolume(session.totalVolume.toStringAsFixed(0)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlanPage(
                        date: repo.ymdToDateTime(session.ymd),
                        repo: repo,
                        exerciseRepo: exerciseRepo,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // 운동 목록
          ...session.exercises.take(3).map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: BurnFitStyle.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${exercise.name} - ${exercise.bodyPart}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: BurnFitStyle.darkGrayText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (session.exercises.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.andMore(session.exercises.length - 3),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

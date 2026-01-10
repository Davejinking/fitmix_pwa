import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../pages/plan_page.dart';

/// Digital Receipt / Terminal Log Style Workout Detail Screen
class LogDetailPage extends StatelessWidget {
  final Session session;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;

  const LogDetailPage({
    super.key,
    required this.session,
    required this.repo,
    required this.exerciseRepo,
  });

  @override
  Widget build(BuildContext context) {
    final date = repo.ymdToDateTime(session.ymd);
    final totalSets = session.exercises.fold(0, (sum, e) => sum + e.sets.length);
    final duration = totalSets * 3; // Estimate: 3 min per set

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF007AFF)),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanPage(
                    date: date,
                    repo: repo,
                    exerciseRepo: exerciseRepo,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. Header (Minimal)
            _buildHeader(context, date),
            
            const SizedBox(height: 24),
            
            // B. Summary Strip (Compact)
            _buildSummaryStrip(context, duration, totalSets),
            
            const SizedBox(height: 32),
            
            // C. Exercise List (The "Log" look)
            _buildExerciseLog(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'WORKOUT LOG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF00C853),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '[COMPLETE]',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00C853),
                    letterSpacing: 0.5,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(BuildContext context, int duration, int totalSets) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('DURATION', '${duration}m'),
          _buildDivider(),
          _buildSummaryItem('VOLUME', '${(session.totalVolume / 1000).toStringAsFixed(1)}t'),
          _buildDivider(),
          _buildSummaryItem('SETS', '$totalSets'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFF2C2C2E),
    );
  }

  Widget _buildExerciseLog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXERCISE LOG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: session.exercises.length,
            separatorBuilder: (context, index) => _buildDashedDivider(),
            itemBuilder: (context, index) {
              final exercise = session.exercises[index];
              return _ExerciseLogTile(exercise: exercise);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              height: 1,
              color: index.isEven ? const Color(0xFF2C2C2E) : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseLogTile extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseLogTile({required this.exercise});

  @override
  State<_ExerciseLogTile> createState() => _ExerciseLogTileState();
}

class _ExerciseLogTileState extends State<_ExerciseLogTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final maxWeightSet = widget.exercise.sets.reduce((a, b) => 
      a.weight > b.weight ? a : b
    );
    final totalVolume = widget.exercise.sets.fold(0.0, 
      (sum, set) => sum + (set.weight * set.reps)
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collapsed State
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Exercise Name
                Expanded(
                  child: Text(
                    widget.exercise.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Summary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.exercise.sets.length} SETS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BEST: ${maxWeightSet.weight.toStringAsFixed(0)}kg',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF007AFF),
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Expanded State
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border.all(
                color: const Color(0xFF2C2C2E),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'SET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'WEIGHT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'REPS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        'VOLUME',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFF2C2C2E)),
                const SizedBox(height: 8),
                // Table Rows
                ...widget.exercise.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  final volume = set.weight * set.reps;
                  final isMaxWeight = set.weight == maxWeightSet.weight;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${set.weight.toStringAsFixed(1)}kg',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isMaxWeight ? const Color(0xFFFF6B35) : Colors.white,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${set.reps}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text(
                            '${volume.toStringAsFixed(0)}kg',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFF2C2C2E)),
                const SizedBox(height: 8),
                // Total Row
                Row(
                  children: [
                    const SizedBox(width: 40),
                    const Expanded(
                      child: Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF007AFF),
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${totalVolume.toStringAsFixed(0)}kg',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF007AFF),
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

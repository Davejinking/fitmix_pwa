import 'package:flutter/material.dart';
import '../../../models/exercise.dart';

/// Industrial/Noir style Exercise Log Card
/// Displays exercise history in a System Log / Data Card format
class ExerciseLogCard extends StatelessWidget {
  final Exercise exercise;
  final double? personalRecord; // PR weight for highlighting
  final VoidCallback? onTap;

  const ExerciseLogCard({
    super.key,
    required this.exercise,
    this.personalRecord,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxWeight = exercise.sets.isEmpty
        ? 0.0
        : exercise.sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    final totalVolume = exercise.sets.fold<double>(
      0.0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark Grey Surface
          border: Border.all(
            color: const Color(0xFF333333), // Thin border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4), // Sharp corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(maxWeight, totalVolume),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            // Data Table
            _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double maxWeight, double totalVolume) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${exercise.sets.length} SETS • ${totalVolume.toStringAsFixed(0)}kg TOTAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Courier',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        // Meta Info (Best Weight)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2979FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFF2979FF).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'BEST',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${maxWeight.toStringAsFixed(1)}kg',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2979FF), // Neon Blue
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Column(
      children: [
        // Table Headers
        _buildTableHeader(),
        const SizedBox(height: 8),
        // Table Rows
        ...exercise.sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final volume = set.weight * set.reps;
          final isPR = personalRecord != null && set.weight >= personalRecord!;
          
          return _buildTableRow(
            setNumber: index + 1,
            weight: set.weight,
            reps: set.reps,
            volume: volume,
            isPR: isPR,
          );
        }),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'SET',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 0.5,
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
                letterSpacing: 0.5,
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
                letterSpacing: 0.5,
                fontFamily: 'Courier',
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              'VOLUME',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 0.5,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required int setNumber,
    required double weight,
    required int reps,
    required double volume,
    required bool isPR,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '$setNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                fontFamily: 'Courier',
              ),
            ),
          ),
          // Weight
          Expanded(
            child: Text(
              '${weight.toStringAsFixed(1)}kg',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPR ? const Color(0xFFFF6B35) : Colors.white, // Orange for PR
                fontFamily: 'Courier',
              ),
            ),
          ),
          // Reps
          Expanded(
            child: Text(
              '$reps',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPR ? const Color(0xFFFF6B35) : Colors.white,
                fontFamily: 'Courier',
              ),
            ),
          ),
          // Volume
          SizedBox(
            width: 70,
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
  }
}

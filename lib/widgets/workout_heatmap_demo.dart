import 'package:flutter/material.dart';
import 'workout_heatmap.dart';

/// Demo page showing how to use WorkoutHeatmap widget
class WorkoutHeatmapDemo extends StatelessWidget {
  const WorkoutHeatmapDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample workout data (DateTime -> Volume in kg)
    final workoutData = _generateSampleData();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'WORKOUT CONSISTENCY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVITY HEATMAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF505050),
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your workout intensity over the past 6 months',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF808080),
                    ),
                  ),
                ],
              ),
            ),
            WorkoutHeatmap(
              workoutData: workoutData,
              monthsToShow: 6,
              onDayTap: (date) {
                // Handle day tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: ${date.toString().split(' ')[0]}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Stats summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsSummary(workoutData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(Map<DateTime, double> data) {
    final totalWorkouts = data.values.where((v) => v > 0).length;
    final totalVolume = data.values.fold(0.0, (sum, v) => sum + v);
    final avgVolume = totalWorkouts > 0 ? totalVolume / totalWorkouts : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('WORKOUTS', '$totalWorkouts'),
          _buildDivider(),
          _buildStatItem('TOTAL VOL', '${(totalVolume / 1000).toStringAsFixed(1)}t'),
          _buildDivider(),
          _buildStatItem('AVG VOL', '${(avgVolume / 1000).toStringAsFixed(1)}t'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF505050),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  /// Generate sample workout data for demonstration
  Map<DateTime, double> _generateSampleData() {
    final data = <DateTime, double>{};
    final now = DateTime.now();
    
    // Generate random workout data for past 6 months
    for (int i = 0; i < 180; i++) {
      final date = now.subtract(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Simulate workout pattern (3-4 days per week)
      if (i % 7 < 4 && (i + date.day) % 3 != 0) {
        // Random volume between 1000-6000 kg
        final volume = 1000 + (date.day * 100) % 5000;
        data[normalizedDate] = volume.toDouble();
      }
    }
    
    return data;
  }
}

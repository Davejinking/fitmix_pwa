import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';

class SummaryChart extends StatelessWidget {
  final List<double> weeklyData; // 7일치 운동 완료 횟수 또는 시간 등

  const SummaryChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppConstants.chartAspectRatio,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 1).clamp(AppConstants.chartMinY, AppConstants.chartMaxY),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = ['월', '화', '수', '목', '금', '토', '일'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(days[value.toInt() % 7]),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[i],
                  color: Theme.of(context).colorScheme.primary,
                  width: AppConstants.chartBarWidth,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

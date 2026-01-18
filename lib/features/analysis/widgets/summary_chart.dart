import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants.dart';

class SummaryChart extends StatelessWidget {
  final List<double> weeklyData; // 7일치 운동 완료 횟수 또는 시간 등

  const SummaryChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final hasData = weeklyData.any((v) => v > 0);
    
    return AspectRatio(
      aspectRatio: AppConstants.chartAspectRatio,
      child: hasData
          ? BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 1).clamp(AppConstants.chartMinY, AppConstants.chartMaxY),
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: false), // 격자선 제거
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['월', '화', '수', '목', '금', '토', '일'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(
                              color: Color(0xFFAAAAAA),
                              fontSize: 12,
                            ),
                          ),
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
                        toY: weeklyData[i] == 0 ? 0.1 : weeklyData[i],
                        color: AppConstants.primaryColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), // 상단만 둥글게
                      ),
                    ],
                  );
                }),
              ),
            )
          : _buildEmptyChart(),
    );
  }

  // 빈 그래프 스켈레톤 UI
  Widget _buildEmptyChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final days = ['월', '화', '수', '목', '금', '토', '일'];
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: 40 + (i * 10.0 % 60),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[i],
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }
}

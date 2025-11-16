import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/burn_fit_style.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';

class AnalysisPage extends StatefulWidget {
  final SessionRepo repo;
  final UserRepo userRepo;

  const AnalysisPage({super.key, required this.repo, required this.userRepo});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

/// 분석 페이지에 필요한 두 가지 데이터를 담는 클래스
class _AnalysisData {
  final Map<String, double> volumeByBodyPart;
  final Map<String, double> monthlyDurations;

  _AnalysisData({required this.volumeByBodyPart, required this.monthlyDurations});
}

class _AnalysisPageState extends State<AnalysisPage> {
  late Future<_AnalysisData> _analysisDataFuture;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _analysisDataFuture = _loadAnalysisData();
  }

  /// 모든 분석 데이터를 한 번에 계산
  Future<_AnalysisData> _loadAnalysisData() async {
    final sessions = await widget.repo.getWorkoutSessions();

    // 1. 부위별 볼륨 계산
    final Map<String, double> volumeByBodyPart = {};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        double exerciseVolume = 0;
        for (final set in exercise.sets) {
          exerciseVolume += set.weight * set.reps;
        }
        volumeByBodyPart.update(
          exercise.bodyPart,
          (value) => value + exerciseVolume,
          ifAbsent: () => exerciseVolume,
        );
      }
    }
    volumeByBodyPart.removeWhere((key, value) => value == 0);

    // 2. 월별 운동 시간 계산
    final Map<String, int> monthlyDurationsInSeconds = {};
    for (final session in sessions) {
      if (session.durationInSeconds > 0) {
        final monthKey = session.ymd.substring(0, 7); // 'yyyy-MM'
        monthlyDurationsInSeconds.update(
          monthKey,
          (value) => value + session.durationInSeconds,
          ifAbsent: () => session.durationInSeconds,
        );
      }
    }

    final sortedKeys = monthlyDurationsInSeconds.keys.toList()..sort();
    final monthlyDurationsInHours = {
      for (var key in sortedKeys) key: monthlyDurationsInSeconds[key]! / 3600.0
    };

    return _AnalysisData(
      volumeByBodyPart: volumeByBodyPart,
      monthlyDurations: monthlyDurationsInHours,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_AnalysisData>(
        future: _analysisDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.volumeByBodyPart.isEmpty) {
            return const Center(child: Text('분석할 운동 기록이 없습니다.'));
          }

          final analysisData = snapshot.data!;
          final volumeData = analysisData.volumeByBodyPart;
          final totalVolume = volumeData.values.fold(0.0, (sum, item) => sum + item);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVolumePieChart(volumeData, totalVolume),
                  const SizedBox(height: 48),
                  _buildDurationLineChart(analysisData.monthlyDurations),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVolumePieChart(Map<String, double> volumeData, double totalVolume) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('부위별 총 볼륨', style: BurnFitStyle.title2),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: List.generate(volumeData.length, (i) {
                final isTouched = i == _touchedIndex;
                final fontSize = isTouched ? 18.0 : 14.0;
                final radius = isTouched ? 100.0 : 90.0;
                final entry = volumeData.entries.elementAt(i);
                final percentage = (entry.value / totalVolume) * 100;

                return PieChartSectionData(
                  color: _getColorForBodyPart(i),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: BurnFitStyle.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(volumeData.length, (i) {
            final entry = volumeData.entries.elementAt(i);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 16, height: 16, color: _getColorForBodyPart(i)),
                const SizedBox(width: 8),
                Text('${entry.key}: ${entry.value.toStringAsFixed(0)} kg'),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDurationLineChart(Map<String, double> durationData) {
    if (durationData.isEmpty) {
      return const SizedBox.shrink(); // 데이터 없으면 표시 안함
    }

    final spots = List.generate(durationData.length, (index) {
          return FlSpot(index.toDouble(), durationData.values.elementAt(index));
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('월별 총 운동 시간', style: BurnFitStyle.title2),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < durationData.length) {
                            // '2023-09' -> '9월'
                            final month = int.parse(durationData.keys.elementAt(index).substring(5, 7));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${month}월'),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: BurnFitStyle.mediumGray),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: BurnFitStyle.primaryBlue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: BurnFitStyle.primaryBlue.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)} 시간',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
  }

  Color _getColorForBodyPart(int index) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink
    ];
    return colors[index % colors.length];
  }
}

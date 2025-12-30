import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../l10n/app_localizations.dart';

class AnalysisPage extends StatefulWidget {
  final SessionRepo repo;
  final UserRepo userRepo;

  const AnalysisPage({super.key, required this.repo, required this.userRepo});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

/// 분석 페이지에 필요한 데이터를 담는 클래스
class _AnalysisData {
  final Map<String, double> volumeByBodyPart;
  final Map<String, double> monthlyDurations;
  final Map<String, int> setsByBodyPart; // 부위별 세트 수
  final String? weakestBodyPart; // 가장 부족한 부위
  final List<String> weakPoints; // 약점 부위 (하위 2개)

  _AnalysisData({
    required this.volumeByBodyPart,
    required this.monthlyDurations,
    required this.setsByBodyPart,
    this.weakestBodyPart,
    this.weakPoints = const [],
  });
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
    // 최근 30일 데이터 가져오기
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentSessions = await widget.repo.getSessionsInRange(thirtyDaysAgo, now);

    // 1. 부위별 볼륨 계산
    final Map<String, double> volumeByBodyPart = {};
    final Map<String, int> setsByBodyPart = {};
    
    for (final session in recentSessions) {
      for (final exercise in session.exercises) {
        double exerciseVolume = 0;
        int setCount = exercise.sets.length;
        
        for (final set in exercise.sets) {
          exerciseVolume += set.weight * set.reps;
        }
        
        volumeByBodyPart.update(
          exercise.bodyPart,
          (value) => value + exerciseVolume,
          ifAbsent: () => exerciseVolume,
        );
        
        setsByBodyPart.update(
          exercise.bodyPart,
          (value) => value + setCount,
          ifAbsent: () => setCount,
        );
      }
    }
    volumeByBodyPart.removeWhere((key, value) => value == 0);

    // 가장 부족한 부위 찾기 (6대 부위 중)
    final mainBodyParts = ['가슴', '등', '하체', '어깨', '팔', '복근'];
    String? weakestBodyPart;
    int minSets = 999999;
    
    for (final part in mainBodyParts) {
      final sets = setsByBodyPart[part] ?? 0;
      if (sets < minSets) {
        minSets = sets;
        weakestBodyPart = part;
      }
    }

    // 약점 부위 찾기 (하위 2개, 유산소/스트레칭 제외)
    final List<String> weakPoints = [];
    if (setsByBodyPart.isNotEmpty) {
      // 부위별 세트 수를 리스트로 변환하고 정렬
      final sortedParts = mainBodyParts.map((part) {
        return MapEntry(part, setsByBodyPart[part] ?? 0);
      }).toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      // 하위 2개 선정 (세트 수가 0보다 큰 경우만)
      for (final entry in sortedParts) {
        if (weakPoints.length >= 2) break;
        if (entry.value >= 0) { // 0도 포함 (운동 안 한 부위)
          weakPoints.add(entry.key);
        }
      }
    }

    // 2. 월별 운동 시간 계산 (전체 기간)
    final allSessions = await widget.repo.getWorkoutSessions();
    final Map<String, int> monthlyDurationsInSeconds = {};
    for (final session in allSessions) {
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
      setsByBodyPart: setsByBodyPart,
      weakestBodyPart: weakestBodyPart,
      weakPoints: weakPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF121212),
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.analysisTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            // 본문
            Expanded(
              child: FutureBuilder<_AnalysisData>(
        future: _analysisDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context).errorOccurred(snapshot.error.toString())));
          }
          if (!snapshot.hasData || snapshot.data!.volumeByBodyPart.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).noAnalysisData));
          }

          final analysisData = snapshot.data!;
          final volumeData = analysisData.volumeByBodyPart;
          final totalVolume = volumeData.values.fold(0.0, (sum, item) => sum + item);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBodyBalanceRadarChart(analysisData),
                  const SizedBox(height: 20),
                  _buildWeakPointsCard(analysisData),
                  const SizedBox(height: 20),
                  _buildVolumePieChart(volumeData, totalVolume),
                  const SizedBox(height: 20),
                  _buildDurationLineChart(analysisData.monthlyDurations),
                  const SizedBox(height: 20), // 하단 여백
                ],
              ),
            ),
          );
        },
      ),
      ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumePieChart(Map<String, double> volumeData, double totalVolume) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.volumeByBodyPart,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                PieChart(
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
                    centerSpaceRadius: 70, // 도넛 차트 중앙 공간 확대
                    sections: List.generate(volumeData.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final fontSize = isTouched ? 16.0 : 0.0; // 터치 시에만 표시
                      final radius = isTouched ? 100.0 : 90.0;
                      final entry = volumeData.entries.elementAt(i);
                      final percentage = (entry.value / totalVolume) * 100;

                      return PieChartSectionData(
                        color: _getColorForBodyPart(i),
                        value: entry.value,
                        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFFFF),
                        ),
                      );
                    }),
                  ),
                ),
                // 중앙 텍스트
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '총 볼륨',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalVolume.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: List.generate(volumeData.length, (i) {
              final entry = volumeData.entries.elementAt(i);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getColorForBodyPart(i),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationLineChart(Map<String, double> durationData) {
    if (durationData.isEmpty) {
      return const SizedBox.shrink(); // 데이터 없으면 표시 안함
    }

    final spots = List.generate(durationData.length, (index) {
      return FlSpot(index.toDouble(), durationData.values.elementAt(index));
    });

    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyWorkoutTime,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false), // 그리드 제거
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Y축 제거
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
                            child: Text(
                              '$month월',
                              style: const TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false), // 테두리 제거
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true, // 부드러운 곡선
                    color: const Color(0xFF007AFF), // 포인트 컬러
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF007AFF).withValues(alpha: 0.3),
                          const Color(0xFF007AFF).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          l10n.hours(spot.y.toStringAsFixed(1)),
                          const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForBodyPart(int index) {
    // 블루 톤앤매너로 통일 (명도 차이)
    final colors = [
      const Color(0xFF007AFF), // 메인 블루
      const Color(0xFF409CFF), // 밝은 블루
      const Color(0xFF0051D5), // 어두운 블루
      const Color(0xFF80BFFF), // 연한 블루
      const Color(0xFF0066FF), // 중간 블루
      const Color(0xFF5CADFF), // 하늘색
      const Color(0xFF003D99), // 진한 블루
    ];
    return colors[index % colors.length];
  }

  // 신체 밸런스 레이더 차트
  Widget _buildBodyBalanceRadarChart(_AnalysisData data) {
    final mainBodyParts = ['가슴', '등', '하체', '어깨', '팔', '복근'];
    final setsByBodyPart = data.setsByBodyPart;
    final l10n = AppLocalizations.of(context);
    
    // 데이터가 없으면 표시하지 않음
    if (setsByBodyPart.isEmpty) {
      return const SizedBox.shrink();
    }

    // 최대값 찾기
    int maxSets = 0;
    for (final part in mainBodyParts) {
      final sets = setsByBodyPart[part] ?? 0;
      if (sets > maxSets) maxSets = sets;
    }

    // 최대값이 0이면 표시하지 않음
    if (maxSets == 0) {
      return const SizedBox.shrink();
    }

    // 각 부위의 점수 계산 (0~100)
    final scores = mainBodyParts.map((part) {
      final sets = setsByBodyPart[part] ?? 0;
      return (sets / maxSets * 100).toDouble();
    }).toList();

    // 인사이트 생성
    final weakest = data.weakestBodyPart ?? '하체';
    final weakestSets = setsByBodyPart[weakest] ?? 0;
    final strongestPart = mainBodyParts.reduce((a, b) => 
      (setsByBodyPart[a] ?? 0) > (setsByBodyPart[b] ?? 0) ? a : b
    );
    final strongestSets = setsByBodyPart[strongestPart] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bodyBalanceAnalysis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.last30DaysSets,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                radarBorderData: const BorderSide(color: Color(0xFF2C2C2E), width: 2),
                gridBorderData: const BorderSide(color: Color(0xFF2C2C2E), width: 1),
                tickBorderData: const BorderSide(color: Colors.transparent),
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: mainBodyParts[index],
                    angle: angle,
                  );
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF007AFF).withValues(alpha: 0.4),
                    borderColor: const Color(0xFF007AFF),
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: scores.map((score) => RadarEntry(value: score)).toList(),
                  ),
                ],
                titleTextStyle: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 인사이트
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF007AFF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.analysisResult,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '회원님은 현재 $strongestPart 운동 비중이 높고($strongestSets세트), $weakest 운동이 부족합니다($weakestSets세트).',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/library', arguments: weakest);
                  },
                  icon: const Icon(Icons.fitness_center, size: 18),
                  label: Text('$weakest 운동 하러 가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 약점 부위 카드
  Widget _buildWeakPointsCard(_AnalysisData data) {
    final weakPoints = data.weakPoints;
    
    // 약점이 없으면 표시하지 않음
    if (weakPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final setsByBodyPart = data.setsByBodyPart;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF3B30),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '집중 공략 필요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '현재 ${weakPoints.join('과 ')} 운동 비중이 낮습니다. 밸런스를 위해 조금 더 신경 써주세요!',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFAAAAAA),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // 약점 부위 표시
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: weakPoints.map((part) {
              final sets = setsByBodyPart[part] ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      color: Color(0xFFFF3B30),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      part,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$sets세트',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // 보완 운동 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/library', arguments: weakPoints.first);
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('보완 운동 하러 가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

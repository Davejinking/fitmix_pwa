import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

enum TimeRange { week, month, year }

enum ChartWidget {
  consistency,
  bodyComposition,
  strengthProgress,
  monthlyVolume,
}

class ProfileAnalyticsScreen extends StatefulWidget {
  const ProfileAnalyticsScreen({super.key});

  @override
  State<ProfileAnalyticsScreen> createState() => _ProfileAnalyticsScreenState();
}

class _ProfileAnalyticsScreenState extends State<ProfileAnalyticsScreen> {
  // Visible widgets state
  List<ChartWidget> _visibleWidgets = [
    ChartWidget.consistency,
    ChartWidget.bodyComposition,
    ChartWidget.strengthProgress,
    ChartWidget.monthlyVolume,
  ];
  
  // Body Composition Tab State
  int _bodyCompTab = 0; // 0: Weight, 1: Body Fat, 2: Muscle Mass
  TimeRange _bodyCompTimeRange = TimeRange.month;
  
  // Strength Progress State
  String _selectedExercise = 'Bench Press';
  bool _showEstimated1RM = true; // true: 1RM, false: Max Volume
  TimeRange _strengthTimeRange = TimeRange.month;
  
  // Monthly Volume State
  TimeRange _volumeTimeRange = TimeRange.month;
  
  final List<String> _exercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
  ];

  void _showWidgetSelector() {
    showMenu<ChartWidget>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 280, // Right aligned
        100, // Below header
        20,
        0,
      ),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      items: [
        _buildPopupMenuItem(
          ChartWidget.consistency,
          'Yearly Consistency',
          Icons.calendar_today,
        ),
        _buildPopupMenuItem(
          ChartWidget.bodyComposition,
          'Body Composition',
          Icons.monitor_weight,
        ),
        _buildPopupMenuItem(
          ChartWidget.strengthProgress,
          'Strength Progress',
          Icons.trending_up,
        ),
        _buildPopupMenuItem(
          ChartWidget.monthlyVolume,
          'Total Volume',
          Icons.bar_chart,
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          if (_visibleWidgets.contains(value)) {
            _visibleWidgets.remove(value);
          } else {
            _visibleWidgets.add(value);
          }
        });
      }
    });
  }

  PopupMenuItem<ChartWidget> _buildPopupMenuItem(
    ChartWidget widget,
    String title,
    IconData icon,
  ) {
    final isVisible = _visibleWidgets.contains(widget);
    
    return PopupMenuItem<ChartWidget>(
      value: widget,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF007AFF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              isVisible ? Icons.check_circle : Icons.circle_outlined,
              color: isVisible ? const Color(0xFF007AFF) : const Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              // Dynamically render visible widgets
              ..._visibleWidgets.map((widget) {
                Widget chartWidget;
                switch (widget) {
                  case ChartWidget.consistency:
                    chartWidget = _buildConsistencyHeatmap();
                    break;
                  case ChartWidget.bodyComposition:
                    chartWidget = _buildBodyCompositionSection();
                    break;
                  case ChartWidget.strengthProgress:
                    chartWidget = _buildStrengthProgressSection();
                    break;
                  case ChartWidget.monthlyVolume:
                    chartWidget = _buildMonthlyVolumeSection();
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: chartWidget,
                );
              }).toList(),
              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'IRON ANALYTICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 2.5,
                ),
              ),
              // Add Widget button - small and simple
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showWidgetSelector,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF007AFF),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.add,
                          color: Color(0xFF007AFF),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Widget',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Performance Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('142 Days', 'Active', const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildStatChip('38.9%', 'Consistency', const Color(0xFF007AFF)),
              const SizedBox(width: 12),
              _buildStatChip('+12.5kg', 'Total Gain', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyHeatmap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YEARLY CONSISTENCY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '142 Days Active',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildHeatmapGrid(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Less',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 4),
              _buildHeatmapLegend(const Color(0xFF1E293B)),
              const SizedBox(width: 2),
              _buildHeatmapLegend(const Color(0xFF10B981).withValues(alpha: 0.3)),
              const SizedBox(width: 2),
              _buildHeatmapLegend(const Color(0xFF10B981).withValues(alpha: 0.6)),
              const SizedBox(width: 2),
              _buildHeatmapLegend(const Color(0xFF10B981)),
              const SizedBox(width: 4),
              const Text(
                'More',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    // Generate 365 days of dummy data
    final random = math.Random(42);
    return SizedBox(
      height: 100,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 53, // ~52 weeks
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: 365,
        itemBuilder: (context, index) {
          final intensity = random.nextDouble();
          Color color;
          if (intensity < 0.4) {
            color = Colors.white.withValues(alpha: 0.05); // Darker inactive dots
          } else if (intensity < 0.6) {
            color = const Color(0xFF10B981).withValues(alpha: 0.3);
          } else if (intensity < 0.8) {
            color = const Color(0xFF10B981).withValues(alpha: 0.6);
          } else {
            color = const Color(0xFF10B981);
          }
          
          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeatmapLegend(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBodyCompositionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BODY COMPOSITION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 2,
                ),
              ),
              _buildTimeRangeSelector(_bodyCompTimeRange, (range) {
                setState(() => _bodyCompTimeRange = range);
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBodyCompTab('Weight', 0),
              const SizedBox(width: 8),
              _buildBodyCompTab('Body Fat %', 1),
              const SizedBox(width: 8),
              _buildBodyCompTab('Muscle Mass', 2),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: _buildBodyCompositionChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(TimeRange currentRange, Function(TimeRange) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeButton('W', TimeRange.week, currentRange, onChanged),
          _buildTimeRangeButton('M', TimeRange.month, currentRange, onChanged),
          _buildTimeRangeButton('Y', TimeRange.year, currentRange, onChanged),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(
    String label,
    TimeRange range,
    TimeRange currentRange,
    Function(TimeRange) onChanged,
  ) {
    final isSelected = currentRange == range;
    return GestureDetector(
      onTap: () => onChanged(range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyCompTab(String label, int index) {
    final isSelected = _bodyCompTab == index;
    return GestureDetector(
      onTap: () => setState(() => _bodyCompTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFEF4444).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFEF4444)
                : const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyCompositionChart() {
    final spots = _getBodyCompositionData();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getBodyCompXAxisLabel(value.toInt()),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: const Color(0xFFEF4444),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFFEF4444),
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF1E1E1E),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.3),
                  const Color(0xFFEF4444).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        minY: _getBodyCompMinY(),
        maxY: _getBodyCompMaxY(),
      ),
    );
  }

  String _getBodyCompXAxisLabel(int index) {
    switch (_bodyCompTimeRange) {
      case TimeRange.week:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return index >= 0 && index < days.length ? days[index] : '';
      case TimeRange.month:
        const weeks = ['W1', 'W2', 'W3', 'W4'];
        return index >= 0 && index < weeks.length ? weeks[index] : '';
      case TimeRange.year:
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return index >= 0 && index < months.length ? months[index] : '';
    }
  }

  double _getBodyCompMinY() {
    if (_bodyCompTab == 0) return 64; // Weight - slightly lower
    if (_bodyCompTab == 1) return 9; // Body Fat - slightly lower
    return 24; // Muscle Mass - slightly lower
  }

  double _getBodyCompMaxY() {
    if (_bodyCompTab == 0) return 81; // Weight - slightly higher
    if (_bodyCompTab == 1) return 26; // Body Fat - slightly higher
    return 41; // Muscle Mass - slightly higher
  }

  List<FlSpot> _getBodyCompositionData() {
    // Generate data based on time range and selected metric
    switch (_bodyCompTimeRange) {
      case TimeRange.week:
        return _getWeeklyBodyCompData();
      case TimeRange.month:
        return _getMonthlyBodyCompData();
      case TimeRange.year:
        return _getYearlyBodyCompData();
    }
  }

  List<FlSpot> _getWeeklyBodyCompData() {
    if (_bodyCompTab == 0) {
      // Weight - 7 days
      return [
        const FlSpot(0, 72.5),
        const FlSpot(1, 72.3),
        const FlSpot(2, 72.4),
        const FlSpot(3, 72.2),
        const FlSpot(4, 72.1),
        const FlSpot(5, 72.0),
        const FlSpot(6, 71.9),
      ];
    } else if (_bodyCompTab == 1) {
      // Body Fat %
      return [
        const FlSpot(0, 15.5),
        const FlSpot(1, 15.4),
        const FlSpot(2, 15.4),
        const FlSpot(3, 15.3),
        const FlSpot(4, 15.2),
        const FlSpot(5, 15.2),
        const FlSpot(6, 15.1),
      ];
    } else {
      // Muscle Mass
      return [
        const FlSpot(0, 34.2),
        const FlSpot(1, 34.3),
        const FlSpot(2, 34.3),
        const FlSpot(3, 34.4),
        const FlSpot(4, 34.5),
        const FlSpot(5, 34.5),
        const FlSpot(6, 34.6),
      ];
    }
  }

  List<FlSpot> _getMonthlyBodyCompData() {
    if (_bodyCompTab == 0) {
      // Weight - 4 weeks
      return [
        const FlSpot(0, 73.5),
        const FlSpot(1, 73.0),
        const FlSpot(2, 72.5),
        const FlSpot(3, 72.0),
      ];
    } else if (_bodyCompTab == 1) {
      // Body Fat %
      return [
        const FlSpot(0, 16.0),
        const FlSpot(1, 15.7),
        const FlSpot(2, 15.4),
        const FlSpot(3, 15.0),
      ];
    } else {
      // Muscle Mass
      return [
        const FlSpot(0, 33.5),
        const FlSpot(1, 34.0),
        const FlSpot(2, 34.5),
        const FlSpot(3, 35.0),
      ];
    }
  }

  List<FlSpot> _getYearlyBodyCompData() {
    if (_bodyCompTab == 0) {
      // Weight - 12 months
      return [
        const FlSpot(0, 78),
        const FlSpot(1, 77),
        const FlSpot(2, 76),
        const FlSpot(3, 75.5),
        const FlSpot(4, 75),
        const FlSpot(5, 74.5),
        const FlSpot(6, 74),
        const FlSpot(7, 73.5),
        const FlSpot(8, 73),
        const FlSpot(9, 72.5),
        const FlSpot(10, 72.2),
        const FlSpot(11, 72),
      ];
    } else if (_bodyCompTab == 1) {
      // Body Fat %
      return [
        const FlSpot(0, 20),
        const FlSpot(1, 19.5),
        const FlSpot(2, 19),
        const FlSpot(3, 18.5),
        const FlSpot(4, 18),
        const FlSpot(5, 17.5),
        const FlSpot(6, 17),
        const FlSpot(7, 16.5),
        const FlSpot(8, 16),
        const FlSpot(9, 15.5),
        const FlSpot(10, 15.2),
        const FlSpot(11, 15),
      ];
    } else {
      // Muscle Mass
      return [
        const FlSpot(0, 30),
        const FlSpot(1, 30.5),
        const FlSpot(2, 31),
        const FlSpot(3, 31.5),
        const FlSpot(4, 32),
        const FlSpot(5, 32.5),
        const FlSpot(6, 33),
        const FlSpot(7, 33.5),
        const FlSpot(8, 34),
        const FlSpot(9, 34.5),
        const FlSpot(10, 34.8),
        const FlSpot(11, 35),
      ];
    }
  }

  Widget _buildStrengthProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STRENGTH PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedExercise,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    underline: Container(),
                    items: _exercises.map((exercise) {
                      return DropdownMenuItem(
                        value: exercise,
                        child: Text(exercise),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedExercise = value);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildTimeRangeSelector(_strengthTimeRange, (range) {
                    setState(() => _strengthTimeRange = range);
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricToggle('Estimated 1RM', true),
              const SizedBox(width: 8),
              _buildMetricToggle('Max Volume', false),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: _buildStrengthProgressChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricToggle(String label, bool is1RM) {
    final isSelected = _showEstimated1RM == is1RM;
    return GestureDetector(
      onTap: () => setState(() => _showEstimated1RM = is1RM),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF007AFF).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF007AFF)
                : const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthProgressChart() {
    final spots = _getStrengthProgressData();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _showEstimated1RM ? 5 : 200,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}${_showEstimated1RM ? 'kg' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getStrengthXAxisLabel(value.toInt()),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}${_showEstimated1RM ? 'kg' : ''}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: const Color(0xFF007AFF),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF007AFF),
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF1E1E1E),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthXAxisLabel(int index) {
    return _getBodyCompXAxisLabel(index); // Reuse same logic
  }

  List<FlSpot> _getStrengthProgressData() {
    final base1RM = _selectedExercise == 'Bench Press' ? 80.0 : 
                    _selectedExercise == 'Squat' ? 100.0 :
                    _selectedExercise == 'Deadlift' ? 120.0 : 60.0;
    
    final baseVolume = base1RM * 15; // Rough volume calculation
    
    switch (_strengthTimeRange) {
      case TimeRange.week:
        return _showEstimated1RM
            ? List.generate(7, (i) => FlSpot(i.toDouble(), base1RM + i * 0.5))
            : List.generate(7, (i) => FlSpot(i.toDouble(), baseVolume + i * 50));
      case TimeRange.month:
        return _showEstimated1RM
            ? List.generate(4, (i) => FlSpot(i.toDouble(), base1RM + i * 2.5))
            : List.generate(4, (i) => FlSpot(i.toDouble(), baseVolume + i * 150));
      case TimeRange.year:
        return _showEstimated1RM
            ? List.generate(12, (i) => FlSpot(i.toDouble(), base1RM + i * 1.0))
            : List.generate(12, (i) => FlSpot(i.toDouble(), baseVolume + i * 60));
    }
  }

  Widget _buildMonthlyVolumeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL VOLUME (TONNAGE)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Progressive Overload',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              _buildTimeRangeSelector(_volumeTimeRange, (range) {
                setState(() => _volumeTimeRange = range);
              }),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: _buildMonthlyVolumeChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyVolumeChart() {
    final barGroups = _getVolumeBarGroups();
    
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.05),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}k',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getVolumeXAxisLabel(value.toInt()),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${(rod.toY / 1000).toStringAsFixed(1)}k kg',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getVolumeXAxisLabel(int index) {
    return _getBodyCompXAxisLabel(index); // Reuse same logic
  }

  List<BarChartGroupData> _getVolumeBarGroups() {
    switch (_volumeTimeRange) {
      case TimeRange.week:
        return List.generate(7, (i) => _buildBarGroup(i, 3000.0 + i * 200));
      case TimeRange.month:
        return List.generate(4, (i) => _buildBarGroup(i, 12000.0 + i * 2500));
      case TimeRange.year:
        return List.generate(12, (i) => _buildBarGroup(i, 12000.0 + i * 900));
    }
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF00FF00),
          width: 24,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF00FF00).withValues(alpha: 0.6),
              const Color(0xFF00FF00),
            ],
          ),
        ),
      ],
    );
  }
}

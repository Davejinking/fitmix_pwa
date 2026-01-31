import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class ProfileAnalyticsScreen extends StatefulWidget {
  const ProfileAnalyticsScreen({super.key});

  @override
  State<ProfileAnalyticsScreen> createState() => _ProfileAnalyticsScreenState();
}

class _ProfileAnalyticsScreenState extends State<ProfileAnalyticsScreen> {
  // Body Composition Tab State
  int _bodyCompTab = 0; // 0: Weight, 1: Body Fat, 2: Muscle Mass
  
  // Strength Progress State
  String _selectedExercise = 'Bench Press';
  bool _showEstimated1RM = true; // true: 1RM, false: Max Volume
  
  final List<String> _exercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
  ];

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
              _buildConsistencyHeatmap(),
              const SizedBox(height: 16),
              _buildBodyCompositionSection(),
              const SizedBox(height: 16),
              _buildStrengthProgressSection(),
              const SizedBox(height: 16),
              _buildMonthlyVolumeSection(),
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
          const Text(
            'IRON ANALYTICS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 2.5,
            ),
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
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: 365,
        itemBuilder: (context, index) {
          final intensity = random.nextDouble();
          Color color;
          if (intensity < 0.4) {
            color = const Color(0xFF1E293B); // No workout
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
          const Text(
            'BODY COMPOSITION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 2,
            ),
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
            height: 200,
            child: _buildBodyCompositionChart(),
          ),
        ],
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
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
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
        minY: 65,
        maxY: 80,
      ),
    );
  }

  List<FlSpot> _getBodyCompositionData() {
    if (_bodyCompTab == 0) {
      // Weight data
      return [
        const FlSpot(0, 75),
        const FlSpot(1, 74.5),
        const FlSpot(2, 73.8),
        const FlSpot(3, 73.2),
        const FlSpot(4, 72.5),
        const FlSpot(5, 72),
      ];
    } else if (_bodyCompTab == 1) {
      // Body Fat %
      return [
        const FlSpot(0, 18),
        const FlSpot(1, 17.5),
        const FlSpot(2, 16.8),
        const FlSpot(3, 16.2),
        const FlSpot(4, 15.5),
        const FlSpot(5, 15),
      ];
    } else {
      // Muscle Mass
      return [
        const FlSpot(0, 32),
        const FlSpot(1, 32.5),
        const FlSpot(2, 33.2),
        const FlSpot(3, 33.8),
        const FlSpot(4, 34.5),
        const FlSpot(5, 35),
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
            height: 200,
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
    final spots = _showEstimated1RM 
        ? [
            const FlSpot(0, 80),
            const FlSpot(1, 82.5),
            const FlSpot(2, 85),
            const FlSpot(3, 87.5),
            const FlSpot(4, 90),
            const FlSpot(5, 92.5),
          ]
        : [
            const FlSpot(0, 1200),
            const FlSpot(1, 1350),
            const FlSpot(2, 1500),
            const FlSpot(3, 1650),
            const FlSpot(4, 1800),
            const FlSpot(5, 1950),
          ];
    
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
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
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
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildMonthlyVolumeChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyVolumeChart() {
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
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 12000),
          _buildBarGroup(1, 14500),
          _buildBarGroup(2, 16800),
          _buildBarGroup(3, 18200),
          _buildBarGroup(4, 20500),
          _buildBarGroup(5, 22800),
        ],
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

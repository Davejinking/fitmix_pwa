import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/service_locator.dart';
import '../data/user_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/session_repo.dart';
import '../data/settings_repo.dart';
import '../data/auth_repo.dart';
import 'settings_page.dart';
import 'analysis_page.dart';
import 'inventory_page.dart';

/// Professional Profile Screen - High-Tech Athlete Dashboard
/// Design: Noir/Dark Mode with Electric Blue Accents
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: CustomScrollView(
        slivers: [
          // Header with Avatar & Identity
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          
          // Pro Stat Board (Radar Chart)
          SliverToBoxAdapter(
            child: _buildRadarSection(context),
          ),
          
          // Gear Locker
          SliverToBoxAdapter(
            child: _buildGearLocker(),
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Row(
        children: [
          // Avatar Circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF121212),
              border: Border.all(
                color: const Color(0xFF3D5AFE).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Identity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Name',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IRON ELITE',
                    style: TextStyle(
                      color: Color(0xFF3D5AFE),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Settings Icon
          IconButton(
            onPressed: () {
              // Navigate to settings
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userRepo: getIt<UserRepo>(),
                    exerciseRepo: getIt<ExerciseLibraryRepo>(),
                    sessionRepo: getIt<SessionRepo>(),
                    settingsRepo: getIt<SettingsRepo>(),
                    authRepo: getIt<AuthRepo>(),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFFFFFFFF),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to existing analysis page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AnalysisPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'PERFORMANCE PROFILE',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Visual cue for navigation
                Row(
                  children: [
                    Text(
                      'VIEW HISTORY',
                      style: TextStyle(
                        color: const Color(0xFF3D5AFE).withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF3D5AFE).withValues(alpha: 0.8),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Radar Chart
            SizedBox(
              height: 280,
              child: _RadarChart(
                stats: const {
                  'Strength': 0.85,
                  'Hypertrophy': 0.72,
                  'Endurance': 0.58,
                  'Consistency': 0.91,
                  'Technique': 0.76,
                  'Recovery': 0.64,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGearLocker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MY GEAR LOG',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Gear Items
          _buildGearItem('BLT', 'SBD Belt - Black', '420 Sets'),
          _buildGearItem('STR', 'Versa Gripps Pro', '312 Sets'),
          _buildGearItem('KNE', 'Rehband 7mm Sleeves', '856 Sets'),
          _buildGearItem('WRS', 'Rogue Wrist Wraps', '234 Sets'),
          
          const SizedBox(height: 16),
          
          // View All Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InventoryPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: const Color(0xFF000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: const Text(
                'VIEW ALL GEAR',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGearItem(String code, String name, String mileage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Category Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Item Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          
          // Mileage
          Text(
            mileage,
            style: TextStyle(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hexagonal Radar Chart Widget
class _RadarChart extends StatelessWidget {
  final Map<String, double> stats;

  const _RadarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarChartPainter(stats: stats),
      child: Container(),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> stats;

  _RadarChartPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    final sides = stats.length;
    final angle = (2 * math.pi) / sides;

    // Draw background hexagon layers
    final bgPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int layer = 1; layer <= 5; layer++) {
      final layerRadius = radius * (layer / 5);
      _drawPolygon(canvas, center, layerRadius, sides, angle, bgPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // Draw data polygon
    final dataPath = Path();
    final values = stats.values.toList();
    
    for (int i = 0; i < sides; i++) {
      final value = values[i];
      final x = center.dx + radius * value * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * value * math.sin(angle * i - math.pi / 2);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Fill
    final fillPaint = Paint()
      ..color = const Color(0xFF3D5AFE).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFF3D5AFE).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(dataPath, strokePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF3D5AFE)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sides; i++) {
      final value = values[i];
      final x = center.dx + radius * value * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * value * math.sin(angle * i - math.pi / 2);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labels = stats.keys.toList();
    for (int i = 0; i < sides; i++) {
      final labelRadius = radius + 30;
      final x = center.dx + labelRadius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + labelRadius * math.sin(angle * i - math.pi / 2);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides,
      double angle, Paint paint) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

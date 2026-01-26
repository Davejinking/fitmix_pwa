import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../models/session.dart';
import '../models/exercise_db.dart';
import '../l10n/app_localizations.dart';
import 'shell_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SessionRepo sessionRepo;
  late UserRepo userRepo;

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sessionRepo = getIt<SessionRepo>();
    userRepo = getIt<UserRepo>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure Black
      body: SafeArea(
        child: Stack(
          children: [
            // Background grid
            CustomPaint(
              painter: GridPainter(),
              child: Container(),
            ),
            // Main content
            Column(
              children: [
                _buildStealthAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildTopHUD(),
                        const SizedBox(height: 24),
                        _buildActiveDirective(),
                        const SizedBox(height: 24),
                        _buildFlashbangButton(),
                        const SizedBox(height: 32),
                        _buildMissionLogs(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStealthAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          // Title
          const Text(
            'STEALTH COMMAND',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          // Profile icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white, size: 20),
              onPressed: () {
                final shellState = context.findAncestorStateOfType<ShellPageState>();
                shellState?.onItemTapped(3);
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHUD() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getWeeklyStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {
          'totalLoad': 295.0,
          'volume': 12.3,
        };

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHUDCard(
                      'MASS',
                      '${stats['totalLoad']?.toInt() ?? 0}',
                      'KG',
                      Icons.fitness_center,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: _buildHUDCard(
                      'VOL',
                      '${stats['volume']?.toStringAsFixed(1) ?? 0}',
                      'TON',
                      Icons.bar_chart,
                    ),
                  ),
                ],
              ),
            ),
            // L-shaped corner accents
            Positioned(
              top: 0,
              left: 0,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: CornerAccentPainter(isTopLeft: true),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: CornerAccentPainter(isTopLeft: false),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHUDCard(String label, String value, String unit, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF0080FF), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF666666),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0080FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveDirective() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: const Color(0xFF0080FF).withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background dumbbell image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.fitness_center,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE DIRECTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PUSH A',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CHEST / TRICEPS / SHOULDERS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0080FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '6 EXERCISES',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0080FF),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LAST: 48H AGO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlashbangButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        final shellState = context.findAncestorStateOfType<ShellPageState>();
        shellState?.navigateToCalendar();
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // White section with text
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    'START SESSION',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Blue section with play icon
            Container(
              width: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF0080FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MISSION LOGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Session>>(
          future: _getLatestSessions(),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];
            
            if (sessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'NO MISSION DATA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: sessions.take(3).map((session) => _buildMissionLogCard(session)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMissionLogCard(Session session) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    final date = DateTime.parse(session.ymd);
    final now = DateTime.now();
    final difference = now.difference(date);
    final hoursAgo = difference.inHours;
    
    String workoutName;
    if (session.routineName != null && session.routineName!.isNotEmpty) {
      workoutName = session.routineName!;
    } else if (session.exercises.isNotEmpty) {
      final exerciseNames = session.exercises.map((e) {
        try {
          final localizedName = ExerciseDB.getExerciseNameLocalized(e.name, locale);
          return localizedName;
        } catch (_) {
          return e.name.replaceAll('_', ' ');
        }
      }).toList();
      workoutName = exerciseNames.join(' + ');
    } else {
      workoutName = 'WORKOUT SESSION';
    }
    
    // Calculate total volume
    double totalVolume = 0;
    for (var exercise in session.exercises) {
      for (var set in exercise.sets) {
        totalVolume += set.weight * set.reps;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0080FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale == 'en' ? workoutName.toUpperCase() : workoutName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'T-MINUS ${hoursAgo}H',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(totalVolume / 1000).toStringAsFixed(1)} TONNES',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0080FF),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Future<List<Session>> _getLatestSessions() async {
    final sessions = await sessionRepo.getWorkoutSessions();
    sessions.sort((a, b) => b.ymd.compareTo(a.ymd));
    return sessions.take(5).toList();
  }

  Future<Map<String, dynamic>> _getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final sessions = await sessionRepo.getSessionsInRange(startOfWeek, endOfWeek);
    final workoutSessions = sessions.where((s) => s.isWorkoutDay).toList();
    
    double totalLoad = 0;
    double totalVolume = 0;
    
    for (var session in workoutSessions) {
      for (var exercise in session.exercises) {
        for (var set in exercise.sets) {
          final load = set.weight;
          final volume = set.weight * set.reps;
          if (load > totalLoad) totalLoad = load;
          totalVolume += volume;
        }
      }
    }
    
    // Get previous week for comparison
    final prevStartOfWeek = startOfWeek.subtract(const Duration(days: 7));
    final prevEndOfWeek = prevStartOfWeek.add(const Duration(days: 6));
    final prevSessions = await sessionRepo.getSessionsInRange(prevStartOfWeek, prevEndOfWeek);
    final prevWorkoutSessions = prevSessions.where((s) => s.isWorkoutDay).toList();
    
    double prevTotalLoad = 0;
    for (var session in prevWorkoutSessions) {
      for (var exercise in session.exercises) {
        for (var set in exercise.sets) {
          if (set.weight > prevTotalLoad) prevTotalLoad = set.weight;
        }
      }
    }
    
    final loadChange = prevTotalLoad > 0 
        ? ((totalLoad - prevTotalLoad) / prevTotalLoad) * 100 
        : 0.0;
    
    return {
      'totalLoad': totalLoad,
      'loadChange': loadChange,
      'volume': totalVolume / 1000, // Convert to tons
    };
  }

}

// Custom painter for background grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const spacing = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for L-shaped corner accents
class CornerAccentPainter extends CustomPainter {
  final bool isTopLeft;

  CornerAccentPainter({required this.isTopLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0080FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTopLeft) {
      // Top-left L-shape
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else {
      // Bottom-right L-shape
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dashedPath.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

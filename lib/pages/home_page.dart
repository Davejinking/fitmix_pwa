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
                        const SizedBox(height: 16),
                        _buildCycleStatus(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Title
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0088FF), width: 1),
                  color: const Color(0xFF0088FF).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    color: const Color(0xFF0088FF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STEALTH',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3.6,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'Command OS v2.0',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0088FF),
                      letterSpacing: 1.8,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
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
              icon: const Icon(Icons.fingerprint, color: Colors.white, size: 20),
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
          'totalLoad': 92.5,
          'volume': 12.4,
        };

        return Row(
          children: [
            Expanded(
              child: _buildHUDCard(
                'Mass / KG',
                '${stats['totalLoad']?.toStringAsFixed(1) ?? 0}',
                '▲ 0.2',
                Icons.monitor_weight,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHUDCard(
                'Vol / TON',
                '${stats['volume']?.toStringAsFixed(1) ?? 0}',
                'STABLE',
                Icons.bar_chart,
                false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHUDCard(String label, String value, String change, IconData icon, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f0f),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Top right indicator
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0088FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0088FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Bottom gradient line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0088FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF0088FF), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      change,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? const Color(0xFF0088FF) : const Color(0xFF666666),
                        fontFamily: 'Courier',
                      ),
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

  Widget _buildCycleStatus() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a).withValues(alpha: 0.5),
        border: Border(
          left: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cycle Status',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF666666),
              letterSpacing: 2.0,
            ),
          ),
          Row(
            children: [
              _buildStatusBar(true),
              const SizedBox(width: 2),
              _buildStatusBar(false),
              const SizedBox(width: 2),
              _buildStatusBar(true),
              const SizedBox(width: 2),
              _buildStatusBar(true),
              const SizedBox(width: 2),
              _buildStatusBar(false),
              const SizedBox(width: 2),
              _buildStatusBar(false),
              const SizedBox(width: 2),
              _buildStatusBar(false, isNext: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(bool isActive, {bool isNext = false}) {
    return Transform(
      transform: Matrix4.skewX(-0.2),
      child: Container(
        width: 6,
        height: 12,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF0088FF)
              : (isNext 
                  ? Colors.transparent 
                  : const Color(0xFF0f0f0f)),
          border: Border.all(
            color: isActive 
                ? Colors.transparent 
                : Colors.white.withValues(alpha: isNext ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: const Color(0xFF0088FF).withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ] : null,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionButton(Icons.timer, false),
        _buildQuickActionButton(Icons.calculate, false),
        _buildQuickActionButton(Icons.history, true),
        _buildQuickActionButton(Icons.settings, false),
        _buildQuickActionButton(Icons.accessibility_new, false),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, bool isActive) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: ClipPath(
        clipper: CornerClipClipper(),
        child: Container(
          width: 68,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0f0f0f),
            border: Border.all(
              color: isActive 
                  ? const Color(0xFF0088FF).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF666666),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDirective() {
    return ClipPath(
      clipper: BevelClipClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f0f),
          border: Border(
            left: BorderSide(
              color: const Color(0xFF0088FF).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Background image with overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF050505),
                        const Color(0xFF050505).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Directive',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0088FF),
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0088FF),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0088FF).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'READY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Hypertrophy',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFCCCCCC),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'PUSH A',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 0.85,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0088FF).withValues(alpha: 0.1),
                          border: Border(
                            left: BorderSide(
                              color: const Color(0xFF0088FF),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Chest Focus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0088FF),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'ID: P-01-A',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loadout',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF666666),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '6 EXERCISES',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Est. Duration',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF666666),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '65 MIN',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        height: 56,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // White section with text
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Start Session',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Blue section with play icon
                Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088FF),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            // Divider line
            Positioned(
              right: 56,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            // Bottom left corner accent
            Positioned(
              bottom: 0,
              left: 0,
              child: ClipPath(
                clipper: BevelClipClipper(),
                child: Container(
                  width: 8,
                  height: 8,
                  color: Colors.black,
                ),
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
        Container(
          padding: const EdgeInsets.only(bottom: 8),
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
              const Text(
                'Mission Logs',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF666666),
                  letterSpacing: 3.2,
                ),
              ),
              Text(
                'ARCHIVE_ACCESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0088FF),
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Session>>(
          future: _getLatestSessions(),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];
            
            if (sessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f0f).withValues(alpha: 0.5),
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
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
    
    // Format time
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour$minute HRS';
    
    String timeLabel;
    if (hoursAgo < 24) {
      timeLabel = 'Yesterday // $timeStr';
    } else {
      final daysAgo = (hoursAgo / 24).floor();
      timeLabel = 'T-minus ${daysAgo * 24}H // $timeStr';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0f0f0f).withValues(alpha: 0.5),
                border: Border(
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale == 'en' ? workoutName.toUpperCase() : workoutName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF666666),
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (totalVolume / 1000).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        'Tonnes',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF0088FF).withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
            // Corner accents
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

// Custom clipper for bevel effect (12px corner cut)
class BevelClipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const bevel = 12.0;
    
    path.moveTo(bevel, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - bevel);
    path.lineTo(size.width - bevel, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, bevel);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom clipper for corner cut (top-right)
class CornerClipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const corner = 12.0;
    
    path.moveTo(0, 0);
    path.lineTo(size.width - corner, 0);
    path.lineTo(size.width, corner);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for background grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

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

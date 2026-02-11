import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import 'condition_modal.dart';
import 'decision_review_modal.dart';
import 'date_range_selector.dart';
import 'exercise_selector.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF1E88E5);
const Color kPrimaryDark = Color(0xFF1565C0);
const Color kDarkBg = Color(0xFF080808);
const Color kSurfaceDark = Color(0xFF121212);
const Color kCardDark = Color(0xFF0E0E10);
const Color kBorderDark = Color(0xFF1F1F1F);
const Color kTextMuted = Color(0xFF64748B);

class LogScreenV2 extends StatefulWidget {
  const LogScreenV2({super.key});

  @override
  State<LogScreenV2> createState() => _LogScreenV2State();
}

class _LogScreenV2State extends State<LogScreenV2> {
  late SessionRepo repo;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<String> _workoutDates = {};
  Set<String> _restDates = {};
  Map<String, String> _conditionMap = {}; // ymd -> condition ('good', 'okay', 'low')
  Session? _currentSession;
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    repo = getIt<SessionRepo>();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await repo.getAllSessionDates();
    final selectedYmd = repo.ymd(_selectedDay);
    final session = await repo.get(selectedYmd);
    
    // Load condition data for all workout dates
    final conditionMap = <String, String>{};
    for (final ymd in result.workoutDates) {
      final s = await repo.get(ymd);
      if (s?.condition != null) {
        conditionMap[ymd] = s!.condition!;
      }
    }
    
    if (mounted) {
      setState(() {
        _workoutDates = result.workoutDates;
        _restDates = result.restDates;
        _conditionMap = conditionMap;
        _currentSession = session;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBg : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(isDark),
                    _buildDateLabel(isDark),
                    _buildWorkoutLogs(isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final monthYear = DateFormat('MMMM yyyy', 'en_US').format(_focusedDay).toUpperCase();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
              size: 20,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
            child: Column(
              children: [
                Text(
                  'LOG VIEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextMuted,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      monthYear,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'monospace',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: kTextMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                size: 20,
              ),
              onPressed: () => _showReviewModal(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
        ),
      ),
      child: _isCalendarExpanded ? _buildMonthView(isDark) : _buildWeekView(isDark),
    );
  }

  Widget _buildWeekView(bool isDark) {
    // Get current week
    final startOfWeek = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((day) => _buildWeekDayCell(day, isDark)).toList(),
    );
  }

  Widget _buildWeekDayCell(DateTime day, bool isDark) {
    final isSelected = isSameDay(day, _selectedDay);
    final dayYmd = repo.ymd(day);
    final hasWorkout = _workoutDates.contains(dayYmd);
    final condition = _conditionMap[dayYmd];
    
    // Determine dot color based on condition
    Color? dotColor;
    if (condition != null) {
      // Condition recorded - use condition color (larger, higher priority)
      switch (condition) {
        case 'good':
          dotColor = const Color(0xFF10B981); // Green
          break;
        case 'okay':
          dotColor = const Color(0xFFF59E0B); // Yellow
          break;
        case 'low':
          dotColor = const Color(0xFFEF4444); // Red
          break;
      }
    } else if (hasWorkout) {
      // Workout only - use desaturated blue (smaller, lower priority)
      dotColor = const Color(0xFF64748B).withValues(alpha: 0.6);
    }
    
    return GestureDetector(
      onTap: () => _onDaySelected(day),
      child: Container(
        width: 40,
        child: Column(
          children: [
            Text(
              DateFormat('E', 'en_US').format(day).substring(0, 3).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                    ? kPrimaryBlue
                    : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: isSelected ? 36 : 32,
              height: isSelected ? 40 : 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? kPrimaryBlue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isSelected ? 10 : 16),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: kPrimaryBlue.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}'.padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected 
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Condition dot (larger) or workout marker (smaller)
            if (dotColor != null)
              Container(
                width: condition != null ? 6 : 4, // Larger for condition
                height: condition != null ? 6 : 4,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: condition != null ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ] : null,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView(bool isDark) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final endDate = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));
    final totalDays = endDate.difference(startDate).inDays + 1;
    
    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) => 
            SizedBox(
              width: 32,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted,
                ),
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 12),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: totalDays,
          itemBuilder: (context, index) {
            final cellDate = startDate.add(Duration(days: index));
            final isOutside = cellDate.month != _focusedDay.month;
            final isSelected = isSameDay(cellDate, _selectedDay);
            final dayYmd = repo.ymd(cellDate);
            final hasWorkout = _workoutDates.contains(dayYmd);
            final condition = _conditionMap[dayYmd];
            
            // Determine dot color based on condition
            Color? dotColor;
            if (condition != null) {
              // Condition recorded - use condition color
              switch (condition) {
                case 'good':
                  dotColor = const Color(0xFF10B981); // Green
                  break;
                case 'okay':
                  dotColor = const Color(0xFFF59E0B); // Yellow
                  break;
                case 'low':
                  dotColor = const Color(0xFFEF4444); // Red
                  break;
              }
            } else if (hasWorkout) {
              // Workout only - use desaturated blue
              dotColor = const Color(0xFF64748B).withValues(alpha: 0.6);
            }
            
            return GestureDetector(
              onTap: () => _onDaySelected(cellDate),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${cellDate.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isOutside
                            ? (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB))
                            : (isSelected 
                                ? Colors.white
                                : (isDark ? Colors.white : const Color(0xFF0F172A))),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Condition dot (larger) or workout marker (smaller)
                    if (dotColor != null && !isOutside)
                      Container(
                        width: condition != null ? 6 : 4, // Larger for condition
                        height: condition != null ? 6 : 4,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white.withValues(alpha: 0.9)
                              : dotColor,
                          shape: BoxShape.circle,
                          boxShadow: condition != null && !isSelected ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ] : null,
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateLabel(bool isDark) {
    final dateStr = DateFormat('MMM dd, yyyy', 'en_US').format(_selectedDay).toUpperCase();
    final dayYmd = repo.ymd(_selectedDay);
    final hasWorkout = _workoutDates.contains(dayYmd);
    final isRestDay = _restDates.contains(dayYmd);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          Text(
            hasWorkout ? 'SESSION' : (isRestDay ? 'REST_DAY' : 'NO_DATA'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
              letterSpacing: 2.0,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '//',
            style: TextStyle(
              fontSize: 10,
              color: kPrimaryBlue,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kPrimaryBlue,
              letterSpacing: 2.0,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutLogs(bool isDark) {
    if (_currentSession == null || _currentSession!.exercises.isEmpty) {
      final dayYmd = repo.ymd(_selectedDay);
      final isRestDay = _restDates.contains(dayYmd);
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? kCardDark.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  isRestDay ? 'Rest day' : 'No workout logged',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    fontFamily: 'monospace',
                  ),
                ),
                if (!isRestDay) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Log today\'s state',
                    style: TextStyle(
                      fontSize: 11,
                      color: kTextMuted.withValues(alpha: 0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildWorkoutCard(_currentSession!, isDark),
    );
  }

  Widget _buildWorkoutCard(Session session, bool isDark) {
    final totalVolume = session.exercises.fold<double>(
      0,
      (sum, ex) => sum + ex.sets.fold<double>(
        0,
        (setSum, set) => setSum + (set.weight * set.reps),
      ),
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Left blue accent bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: kPrimaryBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
            ),
          ),
          // Main card content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? kCardDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          session.routineName?.toUpperCase() ?? 'WORKOUT SESSION',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showWorkoutMenu(context, session, isDark),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: kTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Row(
                    children: [
                      Text(
                        '${totalVolume.toInt()} KG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextMuted,
                          letterSpacing: 1.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '//',
                        style: TextStyle(
                          fontSize: 11,
                          color: kTextMuted.withValues(alpha: 0.4),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${session.exercises.length} exercises',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kTextMuted,
                          letterSpacing: 1.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Container(
                    height: 1,
                    color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 24),
          // Exercise list
          ...session.exercises.asMap().entries.map((entry) {
            final exercise = entry.value;
            final completedSets = exercise.sets.where((s) => s.isCompleted).length;
            final bestSet = exercise.sets.isNotEmpty 
                ? exercise.sets.reduce((a, b) => a.weight > b.weight ? a : b)
                : null;
            
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < session.exercises.length - 1 ? 20 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completedSets sets',
                          style: TextStyle(
                            fontSize: 10,
                            color: kTextMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bestSet != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${bestSet.weight.toInt()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              ' kg',
                              style: TextStyle(
                                fontSize: 11,
                                color: kTextMuted,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '× ${bestSet.reps}',
                          style: TextStyle(
                            fontSize: 10,
                            color: kTextMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
          // Reflection state (optional metadata)
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data saved',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Add context',
                  style: TextStyle(
                    fontSize: 11,
                    color: kTextMuted.withValues(alpha: 0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutMenu(BuildContext context, Session session, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Primary actions
              _buildMenuItem(
                context,
                icon: Icons.wb_sunny_outlined,
                label: 'Condition',
                onTap: () {
                  Navigator.pop(context);
                  _showConditionModal(context, session);
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                context,
                icon: Icons.rate_review_outlined,
                label: 'Decision review',
                onTap: () {
                  Navigator.pop(context);
                  _showDecisionReviewModal(context, session);
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                context,
                icon: Icons.note_outlined,
                label: 'Note',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to note screen
                },
                isDark: isDark,
              ),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 1,
                color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
              ),
              // Secondary actions
              _buildMenuItem(
                context,
                icon: Icons.edit_outlined,
                label: 'Edit session',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit screen
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                label: 'View details',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to details screen
                },
                isDark: isDark,
              ),
              _buildMenuItem(
                context,
                icon: Icons.content_copy_outlined,
                label: 'Duplicate session',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Duplicate session
                },
                isDark: isDark,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showConditionModal(BuildContext context, Session session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConditionModal(
        sessionDate: repo.ymd(_selectedDay),
      ),
    ).then((result) async {
      if (result != null && mounted) {
        // Save condition data to session
        final level = result['level'] as ConditionLevel;
        final tags = result['tags'] as List<String>;
        
        final updatedSession = session.copyWith(
          condition: level.name,
          conditionTags: tags,
        );
        
        await repo.put(updatedSession);
        _loadData(); // Reload to update UI
      }
    });
  }

  void _showDecisionReviewModal(BuildContext context, Session session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DecisionReviewModal(
        sessionDate: repo.ymd(_selectedDay),
      ),
    ).then((result) async {
      if (result != null && mounted) {
        // Save decision review data to session
        final level = result['level'] as DecisionLevel;
        final reason = result['reason'] as String?;
        
        final updatedSession = session.copyWith(
          decisionReview: level.name,
          decisionReason: reason,
        );
        
        await repo.put(updatedSession);
        _loadData(); // Reload to update UI
      }
    });
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewModal(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'REVIEW BY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: kTextMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 24), // Balance the close button
                  ],
                ),
              ),
              // Options
              Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildReviewOption(
                      context: context,
                      label: 'Date Range',
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await showDialog(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.6),
                          builder: (context) => const DateRangeSelector(),
                        );
                        if (result != null && mounted) {
                          // TODO: Apply date range filter
                          final start = result['start'] as DateTime;
                          final end = result['end'] as DateTime;
                          print('Selected range: ${start.toString()} to ${end.toString()}');
                        }
                      },
                      isDark: isDark,
                    ),
                    _buildReviewOption(
                      context: context,
                      label: 'Exercise',
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await showDialog<Set<String>>(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.6),
                          builder: (context) => const ExerciseSelector(),
                        );
                        if (result != null && mounted) {
                          // TODO: Apply exercise filter
                          print('Selected exercises: $result');
                        }
                      },
                      isDark: isDark,
                    ),
                    _buildReviewOption(
                      context: context,
                      label: 'Condition',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to condition picker
                      },
                      isDark: isDark,
                    ),
                    _buildReviewOption(
                      context: context,
                      label: 'Decision',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⭕',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextMuted.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '△',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextMuted.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '❌',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextMuted.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to decision picker
                      },
                      isDark: isDark,
                    ),
                    _buildReviewOption(
                      context: context,
                      label: 'Notes',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Filter by notes
                      },
                      isDark: isDark,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewOption({
    required BuildContext context,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: isDark ? kBorderDark : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

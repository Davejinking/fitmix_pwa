import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../models/exercise_set.dart';
import '../l10n/app_localizations.dart';
import 'exercise_selection_page_v2.dart';

class CalendarPageNew extends StatefulWidget {
  const CalendarPageNew({super.key});

  @override
  State<CalendarPageNew> createState() => _CalendarPageNewState();
}

class _CalendarPageNewState extends State<CalendarPageNew> {
  late SessionRepo repo;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<String> _workoutDates = {};
  Set<String> _restDates = {};
  Session? _currentSession;
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
    
    if (mounted) {
      setState(() {
        _workoutDates = result.workoutDates;
        _restDates = result.restDates;
        _currentSession = session;
        
        // Auto-collapse logic: if has logs, show 2 weeks; if empty, show month
        final hasLogs = session != null && session.exercises.isNotEmpty;
        _calendarFormat = hasLogs ? CalendarFormat.twoWeeks : CalendarFormat.month;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
    _loadData();
  }
  
  bool get _hasLogs {
    return _currentSession != null && _currentSession!.exercises.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildCalendar(),
            Expanded(
              child: _hasLogs ? _buildLogDetailView() : _buildOperationalMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    // Format month/year based on locale
    final String monthYear;
    if (locale == 'ja') {
      monthYear = DateFormat('yyyy年 M月', 'ja').format(_focusedDay);
    } else if (locale == 'ko') {
      monthYear = DateFormat('yyyy년 M월', 'ko').format(_focusedDay);
    } else {
      final month = DateFormat('MMM', 'en_US').format(_focusedDay).toUpperCase();
      final year = DateFormat('yyyy', 'en_US').format(_focusedDay);
      monthYear = '$month $year';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu button with border
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3F3F46), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 20),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Center content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.calendarTitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF71717A),
                    letterSpacing: locale == 'en' ? 3.0 : 1.0,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  monthYear,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: locale == 'en' ? 2.0 : 0.5,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          
          // Search button with border
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3F3F46), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () {
                // TODO: Show full month calendar modal
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    // Get localized weekday abbreviations
    final weekdays = [
      l10n.weekdayMonAbbr,
      l10n.weekdayTueAbbr,
      l10n.weekdayWedAbbr,
      l10n.weekdayThuAbbr,
      l10n.weekdayFriAbbr,
      l10n.weekdaySatAbbr,
      l10n.weekdaySunAbbr,
    ];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF27272A), width: 1),
        color: const Color(0xFF0A0A0A).withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          // Days of week header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF27272A), width: 1),
              ),
            ),
            child: Row(
              children: weekdays
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF52525B),
                            fontFamily: 'Courier',
                            letterSpacing: locale == 'en' ? 0.5 : 0.0,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Calculate visible range based on calendar format
    int totalDays;
    DateTime startDate;
    
    if (_calendarFormat == CalendarFormat.twoWeeks) {
      // Show 2 weeks (14 days)
      final selectedWeekStart = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
      startDate = selectedWeekStart;
      totalDays = 14;
    } else {
      // Show 3 weeks (21 days) - previous week, current week, next week
      final selectedWeekStart = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
      startDate = selectedWeekStart.subtract(const Duration(days: 7));
      totalDays = 21;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final cellDate = startDate.add(Duration(days: index));
        final isOutside = cellDate.month != _focusedDay.month;
        final isSelected = isSameDay(cellDate, _selectedDay);
        final isToday = isSameDay(cellDate, DateTime.now());
        
        return _buildDayCell(cellDate, isSelected: isSelected, isToday: isToday, isOutside: isOutside);
      },
    );
  }

  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isToday = false, bool isOutside = false}) {
    final dayYmd = repo.ymd(day);
    final hasWorkout = _workoutDates.contains(dayYmd);
    final isRest = _restDates.contains(dayYmd);

    // Decoration Logic: Neon box ONLY for selected date
    BoxDecoration? boxDecoration;
    if (isSelected) {
      boxDecoration = BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      );
    } else {
      // No box decoration for today or normal days
      boxDecoration = const BoxDecoration(
        color: Color(0xFF0A0A0A),
      );
    }

    // Text Style Logic
    Color textColor;
    FontWeight textWeight;
    List<Shadow>? textShadows;

    if (isOutside) {
      // Previous/next month dates
      textColor = Colors.white.withValues(alpha: 0.2);
      textWeight = FontWeight.w400;
      textShadows = null;
    } else if (isToday && !isSelected) {
      // Today (not selected): Blue text, bold, no box
      textColor = const Color(0xFF3B82F6);
      textWeight = FontWeight.w900;
      textShadows = null;
    } else if (isSelected) {
      // Selected date: White text inside neon box
      textColor = Colors.white;
      textWeight = FontWeight.w700;
      textShadows = [
        const Shadow(
          color: Color(0xFF3B82F6),
          blurRadius: 12,
        ),
      ];
    } else {
      // Normal days
      textColor = Colors.white;
      textWeight = FontWeight.w400;
      textShadows = null;
    }

    return GestureDetector(
      onTap: () => _onDaySelected(day, day),
      child: Container(
        decoration: boxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: textWeight,
                shadows: textShadows,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.6),
                      blurRadius: 5,
                    ),
                  ],
                ),
              )
            else if (hasWorkout && !isOutside)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              )
            else if (isRest && !isOutside)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF52525B), width: 1),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4), // 빈 공간 유지
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalMenu() {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final isAsianLanguage = locale != 'en';
    
    final isRestDay = _currentSession?.isRest ?? false;
    final selectedYmd = repo.ymd(_selectedDay);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // START SESSION Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExerciseSelectionPageV2(),
                      ),
                    );
                    _loadData();
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.startSession,
                          style: TextStyle(
                            fontFamily: locale == 'en' ? 'Roboto' : null,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: locale == 'en' ? 1.5 : 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Quick Actions Container (Structured)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionItem(
                    icon: Icons.fitness_center,
                    label: l10n.quickActionRoutine,
                    onTap: () {},
                    isActive: false,
                    isAsianLanguage: isAsianLanguage,
                  ),
                  _buildQuickActionItem(
                    icon: Icons.code,
                    label: l10n.quickActionProgram,
                    onTap: () {},
                    isActive: false,
                    isAsianLanguage: isAsianLanguage,
                  ),
                  _buildQuickActionItem(
                    icon: Icons.calendar_view_day,
                    label: l10n.quickActionPlan,
                    onTap: () {},
                    isActive: false,
                    isAsianLanguage: isAsianLanguage,
                  ),
                  _buildQuickActionItem(
                    icon: Icons.snooze,
                    label: l10n.quickActionRest,
                    onTap: () async {
                      if (isRestDay) {
                        await repo.markRest(selectedYmd, rest: false);
                      } else {
                        await repo.markRest(selectedYmd, rest: true);
                      }
                      _loadData();
                    },
                    isActive: isRestDay,
                    isAsianLanguage: isAsianLanguage,
                  ),
                  _buildQuickActionItem(
                    icon: Icons.edit_note,
                    label: l10n.quickActionLog,
                    onTap: () {},
                    isActive: false,
                    isAsianLanguage: isAsianLanguage,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetailView() {
    if (_currentSession == null) return const SizedBox.shrink();
    
    final session = _currentSession!;
    final dateStr = DateFormat('MMM dd, yyyy').format(_selectedDay).toUpperCase();
    
    // Calculate total volume
    double totalVolume = 0;
    for (var ex in session.exercises) {
      for (var set in ex.sets) {
        if (set.isCompleted) {
          totalVolume += set.weight * set.reps;
        }
      }
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header
            Row(
              children: [
                const Text(
                  'PLANNED_SESSIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF71717A),
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
                const Text(
                  ' // ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF3B82F6),
                    fontFamily: 'Courier',
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                    fontFamily: 'Courier',
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    session.exercises.map((e) => e.name.toUpperCase()).join(' + '),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontFamily: 'Courier',
                      letterSpacing: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtext
                  Text(
                    'TOTAL VOLUME: ${totalVolume.toStringAsFixed(0)} KG // ${session.exercises.length} EXERCISES',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF71717A),
                      fontFamily: 'Courier',
                      letterSpacing: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('COMPLETED'),
                      _buildTag('STRENGTH'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFF27272A),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Exercise List
                  ...session.exercises.map((exercise) {
                    final completedSets = exercise.sets.where((s) => s.isCompleted).length;
                    final totalSets = exercise.sets.length;
                    
                    // Get best set (highest weight)
                    ExerciseSet? bestSet;
                    for (var set in exercise.sets) {
                      if (set.isCompleted && set.weight > 0) {
                        if (bestSet == null || set.weight > bestSet.weight) {
                          bestSet = set;
                        }
                      }
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Exercise name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$completedSets/$totalSets SETS',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF52525B),
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Best set info
                          if (bestSet != null)
                            Text(
                              '${bestSet.weight.toStringAsFixed(0)}KG × ${bestSet.reps}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                                fontFamily: 'Courier',
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('WEEKLY\nFREQUENCY', '4/7'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('CONSISTENCY\nSCORE', '87%'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3B82F6),
          fontFamily: 'Courier',
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF27272A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF71717A),
              fontFamily: 'Courier',
              letterSpacing: 1.0,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
    bool isAsianLanguage = false,
  }) {
    // Dynamic font size based on label length
    // Japanese katakana words like "プログラム" (5 chars) need smaller font
    final fontSize = label.length > 5 ? 9.0 : 10.0;
    
    return SizedBox(
      width: 56, // Reduced from 64 to fix overflow (saves 40px total for 5 items)
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  // Bright white for inactive (metallic), blue for active
                  color: isActive 
                      ? const Color(0xFF3B82F6) 
                      : Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
                const SizedBox(height: 8),
                // FittedBox: Safety net for long text - scales down if needed
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      // Lighter grey for better contrast
                      color: isActive 
                          ? const Color(0xFF3B82F6) 
                          : const Color(0xFF9CA3AF), // grey[400] equivalent
                      fontFamily: 'Courier',
                      letterSpacing: 0.0,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

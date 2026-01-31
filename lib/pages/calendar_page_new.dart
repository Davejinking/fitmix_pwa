import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../models/exercise_set.dart';
import '../l10n/app_localizations.dart';
import 'exercise_selection_page_v2.dart';

// 🎨 Theme Colors (matching HomePage)
const Color kPrimaryBlue = Color(0xFF0D7FF2); // Main accent color
const Color kDarkBg = Color(0xFF101922); // Dark background
const Color kDarkCard = Color(0xFF1E293B); // Card background
const Color kDarkBorder = Color(0xFF334155); // Border color
const Color kTextMuted = Color(0xFF64748B); // Muted text

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
        
        // Always show full month
        _calendarFormat = CalendarFormat.month;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBg : const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isDark),
            _buildCalendar(isDark),
            Expanded(
              child: _hasLogs ? _buildLogDetailView() : _buildOperationalMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
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
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        color: isDark ? kDarkBg : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? kDarkCard : const Color(0xFFF5F7F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? kDarkBorder : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                size: 18,
              ),
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
                    fontWeight: FontWeight.w600,
                    color: kTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthYear,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Search button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? kDarkCard : const Color(0xFFF5F7F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? kDarkBorder : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                size: 18,
              ),
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

  Widget _buildCalendar(bool isDark) {
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
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? kDarkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Days of week header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: weekdays
                  .map((day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar grid
          _buildCalendarGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    // Show full month calendar
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    // Calculate the start date (Monday of the week containing the 1st)
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    
    // Calculate the end date (Sunday of the week containing the last day)
    final endDate = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));
    
    // Calculate total days to display
    final totalDays = endDate.difference(startDate).inDays + 1;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final cellDate = startDate.add(Duration(days: index));
        final isOutside = cellDate.month != _focusedDay.month;
        final isSelected = isSameDay(cellDate, _selectedDay);
        final isToday = isSameDay(cellDate, DateTime.now());
        
        return _buildDayCell(cellDate, isDark, isSelected: isSelected, isToday: isToday, isOutside: isOutside);
      },
    );
  }

  Widget _buildDayCell(DateTime day, bool isDark, {bool isSelected = false, bool isToday = false, bool isOutside = false}) {
    final dayYmd = repo.ymd(day);
    final hasWorkout = _workoutDates.contains(dayYmd);
    final isRest = _restDates.contains(dayYmd);

    // Decoration Logic
    BoxDecoration boxDecoration;
    if (isSelected) {
      boxDecoration = BoxDecoration(
        color: kPrimaryBlue,
        borderRadius: BorderRadius.circular(8),
      );
    } else if (isToday) {
      boxDecoration = BoxDecoration(
        color: isDark 
            ? kPrimaryBlue.withValues(alpha: 0.1)
            : kPrimaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kPrimaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      );
    } else {
      boxDecoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      );
    }

    // Text Style Logic
    Color textColor;
    FontWeight textWeight;

    if (isOutside) {
      textColor = kTextMuted.withValues(alpha: 0.3);
      textWeight = FontWeight.w400;
    } else if (isSelected) {
      textColor = Colors.white;
      textWeight = FontWeight.w700;
    } else if (isToday) {
      textColor = kPrimaryBlue;
      textWeight = FontWeight.w700;
    } else {
      textColor = isDark ? Colors.white : const Color(0xFF0F172A);
      textWeight = FontWeight.w500;
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
                fontSize: 13,
                fontWeight: textWeight,
              ),
            ),
            const SizedBox(height: 4),
            if (hasWorkout && !isOutside)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : kPrimaryBlue,
                  shape: BoxShape.circle,
                ),
              )
            else if (isRest && !isOutside)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.white : kTextMuted,
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
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
            
            // 🔥 QUICK ACCESS Label (Tactical Style)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'QUICK ACCESS',
                style: TextStyle(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            
            // Quick Actions Container (Tactical Noir Style)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF101010), // Darker background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    final fontSize = label.length > 5 ? 9.0 : 10.0;
    
    return SizedBox(
      width: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container (Tactical Button Style)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Button background
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive 
                        ? const Color(0xFF3B82F6) 
                        : Colors.white.withValues(alpha: 0.1),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    if (isActive)
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isActive 
                      ? const Color(0xFF3B82F6) 
                      : Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              
              // Label
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isActive 
                        ? const Color(0xFF3B82F6) 
                        : Colors.grey,
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
    );
  }


}

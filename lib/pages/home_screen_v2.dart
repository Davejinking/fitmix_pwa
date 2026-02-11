import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// 🎨 Theme Colors (matching HomePage)
const Color kPrimaryBlue = Color(0xFF0D7FF2);
const Color kDarkBg = Color(0xFF101922);
const Color kDarkCard = Color(0xFF182634);
const Color kInputDark = Color(0xFF223649);
const Color kTextMuted = Color(0xFF64748B);

class HomeScreenV2 extends StatelessWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBg : const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentSession(isDark),
                    _buildWeeklyPerformance(isDark),
                    _buildQuickActions(isDark),
                    _buildUpcoming(isDark),
                    const SizedBox(height: 80), // Bottom nav space
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: (isDark ? kDarkBg : const Color(0xFFF5F7F8)).withValues(alpha: 0.95),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Alex D.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? kDarkCard : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? kDarkCard : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? kDarkCard : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
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

  Widget _buildCurrentSession(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=400&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upper Body Power',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hypertrophy Program • Week 4, Day 2',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TIME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              '24:15',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'BENCH PRESS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: '3',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: kPrimaryBlue,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/5 Sets',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Set: 12 reps @ 185lbs',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              'Rest: 00:45',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: kPrimaryBlue.withValues(alpha: 0.25),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Resume Session',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildWeeklyPerformance(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'View Report',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              size: 18,
                              color: Color(0xFFF97316),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Calories',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '2,450',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              '▲ 12%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.timer,
                              size: 18,
                              color: kPrimaryBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '4.5h',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '/ 6h Goal',
                              style: TextStyle(
                                fontSize: 11,
                                color: kTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? kDarkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBarChart(0.4, false, isDark),
                      _buildBarChart(0.7, false, isDark),
                      _buildBarChart(0.5, false, isDark),
                      _buildBarChart(0.9, false, isDark),
                      _buildBarChart(0.6, true, isDark),
                      _buildBarChart(0.2, false, isDark),
                      _buildBarChart(0.2, false, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayLabel('Mon', false, isDark),
                    _buildDayLabel('Tue', false, isDark),
                    _buildDayLabel('Wed', false, isDark),
                    _buildDayLabel('Thu', false, isDark),
                    _buildDayLabel('Today', true, isDark),
                    _buildDayLabel('Sat', false, isDark),
                    _buildDayLabel('Sun', false, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(double value, bool isToday, bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFE2E8F0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          child: FractionallySizedBox(
            heightFactor: value,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: isToday 
                    ? kPrimaryBlue
                    : (value > 0.3 
                        ? kPrimaryBlue.withValues(alpha: 0.3)
                        : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabel(String label, bool isToday, bool isDark) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isToday 
              ? (isDark ? Colors.white : const Color(0xFF0F172A))
              : kTextMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionButton(
                  'Log Workout',
                  Icons.add_circle,
                  kPrimaryBlue,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildQuickActionButton(
                  'Log Meal',
                  Icons.restaurant,
                  const Color(0xFFF97316),
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildQuickActionButton(
                  'Water',
                  Icons.water_drop,
                  const Color(0xFF60A5FA),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color iconColor, bool isDark) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? kInputDark : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcoming(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Full Schedule',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildUpcomingCard(
            'TOM',
            '09',
            'Leg Day: Squat Focus',
            '17:00',
            '60 min',
            isDark,
          ),
          const SizedBox(height: 12),
          _buildUpcomingCard(
            'SAT',
            '11',
            'Active Recovery Yoga',
            '09:00',
            '30 min',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(
    String dayLabel,
    String dayNumber,
    String title,
    String time,
    String duration,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: kTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dayNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: kTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: kTextMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 11,
                        color: kTextMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 11,
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF2979FF);
const Color kDarkBg = Color(0xFF101010);
const Color kCardDark = Color(0xFF1A1A1A);
const Color kCardLight = Color(0xFFFFFFFF);

class LogReviewScreen extends StatelessWidget {
  const LogReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? kDarkBg : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color(0xFF1A1A1A) 
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark 
                            ? const Color(0xFFD1D5DB) 
                            : const Color(0xFF374151),
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'REVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: isDark 
                          ? const Color(0xFF9CA3AF) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Reset filters
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark 
                            ? const Color(0xFF9CA3AF) 
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Title section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  Text(
                    'Find logs by',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to review past sessions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark 
                          ? const Color(0xFF9CA3AF) 
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  _buildFilterOption(
                    context: context,
                    icon: Icons.date_range_outlined,
                    iconColor: kPrimaryBlue,
                    iconBgColor: isDark 
                        ? kPrimaryBlue.withValues(alpha: 0.2)
                        : const Color(0xFFDCEEFF),
                    title: 'Date Range',
                    subtitle: 'Select a specific timeframe',
                    onTap: () {
                      // TODO: Navigate to date range picker
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context: context,
                    icon: Icons.fitness_center_outlined,
                    iconColor: const Color(0xFF9333EA),
                    iconBgColor: isDark 
                        ? const Color(0xFF9333EA).withValues(alpha: 0.2)
                        : const Color(0xFFF3E8FF),
                    title: 'Exercise',
                    subtitle: 'Squat, Bench Press, etc.',
                    onTap: () {
                      // TODO: Navigate to exercise picker
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context: context,
                    icon: Icons.sentiment_neutral_outlined,
                    iconColor: const Color(0xFF059669),
                    iconBgColor: isDark 
                        ? const Color(0xFF059669).withValues(alpha: 0.2)
                        : const Color(0xFFD1FAE5),
                    title: 'Condition',
                    subtitle: null,
                    customSubtitle: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to condition picker
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context: context,
                    icon: Icons.gavel_outlined,
                    iconColor: const Color(0xFFEA580C),
                    iconBgColor: isDark 
                        ? const Color(0xFFEA580C).withValues(alpha: 0.2)
                        : const Color(0xFFFFEDD5),
                    title: 'Decision',
                    subtitle: null,
                    customSubtitle: Row(
                      children: [
                        Text(
                          '⭕',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? const Color(0xFF9CA3AF) 
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '△',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? const Color(0xFF9CA3AF) 
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '❌',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to decision picker
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    context: context,
                    icon: Icons.sticky_note_2_outlined,
                    iconColor: isDark 
                        ? const Color(0xFF9CA3AF) 
                        : const Color(0xFF6B7280),
                    iconBgColor: isDark 
                        ? const Color(0xFF374151) 
                        : const Color(0xFFF3F4F6),
                    title: 'Notes',
                    subtitle: 'Has attached notes',
                    onTap: () {
                      // TODO: Filter by notes
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? customSubtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? kCardDark : kCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark 
                            ? const Color(0xFF9CA3AF) 
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  if (customSubtitle != null) ...[
                    const SizedBox(height: 6),
                    customSubtitle,
                  ],
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: isDark 
                  ? const Color(0xFF4B5563) 
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

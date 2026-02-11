import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reflection_onboarding_overlay.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kDarkBg = Color(0xFF050505);
const Color kModalDark = Color(0xFF161618);
const Color kCardDark = Color(0xFF0F0F10);
const Color kBorderDark = Color(0xFF27272A);
const Color kTextSecondary = Color(0xFFA1A1AA);
const Color kAccentGreen = Color(0xFF10B981);
const Color kAccentYellow = Color(0xFFF59E0B);
const Color kAccentRed = Color(0xFFEF4444);

enum ConditionLevel { good, okay, low }

class ConditionModal extends StatefulWidget {
  final String sessionDate;
  
  const ConditionModal({
    super.key,
    required this.sessionDate,
  });

  @override
  State<ConditionModal> createState() => _ConditionModalState();
}

class _ConditionModalState extends State<ConditionModal> {
  ConditionLevel? _selectedLevel;
  final Set<String> _selectedTags = {};
  
  final List<String> _availableTags = [
    'Fatigued',
    'Heavy',
    'Focused',
    'Distracted',
    'Tight',
    'Recovered',
  ];

  @override
  void initState() {
    super.initState();
    _checkAndShowOnboarding();
  }

  Future<void> _checkAndShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_reflection_onboarding') ?? false;
    
    if (!hasSeenOnboarding && mounted) {
      // Wait a bit for the modal to settle
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          builder: (context) => const ReflectionOnboardingOverlay(),
        );
        
        // Mark as seen
        await prefs.setBool('has_seen_reflection_onboarding', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kModalDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF4B5563) 
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                children: [
                  // Question
                  Text(
                    'How did you feel during\nthis session?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Primary selection (Good/Okay/Low)
                  Row(
                    children: [
                      Expanded(
                        child: _buildLevelButton(
                          level: ConditionLevel.good,
                          label: 'Good',
                          color: kAccentGreen,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLevelButton(
                          level: ConditionLevel.okay,
                          label: 'Okay',
                          color: kAccentYellow,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLevelButton(
                          level: ConditionLevel.low,
                          label: 'Low',
                          color: kAccentRed,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Optional tags label
                  Text(
                    'SELECT TAGS (OPTIONAL)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: kTextSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimaryBlue.withValues(alpha: 0.1)
                                : (isDark ? Colors.transparent : Colors.white),
                            border: Border.all(
                              color: isSelected
                                  ? kPrimaryBlue
                                  : (isDark ? kBorderDark : const Color(0xFFE5E7EB)),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? kPrimaryBlue
                                  : (isDark 
                                      ? const Color(0xFF9CA3AF) 
                                      : const Color(0xFF6B7280)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark 
                                    ? kBorderDark 
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark 
                                  ? const Color(0xFF9CA3AF) 
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedLevel != null
                              ? () {
                                  // TODO: Save condition data
                                  Navigator.pop(context, {
                                    'level': _selectedLevel,
                                    'tags': _selectedTags.toList(),
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            disabledBackgroundColor: kPrimaryBlue.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: kPrimaryBlue.withValues(alpha: 0.25),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required ConditionLevel level,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedLevel == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? kCardDark : const Color(0xFFF9FAFB)),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF111827))
                    : (isDark 
                        ? const Color(0xFFD1D5DB) 
                        : const Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

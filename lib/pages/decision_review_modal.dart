import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reflection_onboarding_overlay.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF0A84FF);
const Color kDarkBg = Color(0xFF000000);
const Color kSurfaceDark = Color(0xFF1C1C1E);
const Color kSurfaceElevatedDark = Color(0xFF2C2C2E);
const Color kModalDark = Color(0xFF151517);
const Color kCardDark = Color(0xFF202022);
const Color kBorderDark = Color(0xFF2C2C2E);
const Color kTextSecondary = Color(0xFF8E8E93);
const Color kYellow = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);

enum DecisionLevel { appropriate, borderline, tooMuch }

class DecisionReviewModal extends StatefulWidget {
  final String sessionDate;
  
  const DecisionReviewModal({
    super.key,
    required this.sessionDate,
  });

  @override
  State<DecisionReviewModal> createState() => _DecisionReviewModalState();
}

class _DecisionReviewModalState extends State<DecisionReviewModal> {
  DecisionLevel? _selectedLevel;
  String? _selectedReason;
  
  final List<String> _reasons = [
    'Recovery was needed',
    'Pushed intentionally',
    'Time constrained',
    'Energy mismatch',
    'Other',
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
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF525252) 
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  children: [
                    // Question
                    Text(
                      'How did today\'s training\nchoice feel?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF000000),
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Primary selection (Appropriate/Borderline/Too much)
                    Row(
                      children: [
                        Expanded(
                          child: _buildLevelButton(
                            level: DecisionLevel.appropriate,
                            symbol: '⭕',
                            label: 'Appropriate',
                            color: kPrimaryBlue,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLevelButton(
                            level: DecisionLevel.borderline,
                            symbol: '△',
                            label: 'Borderline',
                            color: kYellow,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLevelButton(
                            level: DecisionLevel.tooMuch,
                            symbol: '❌',
                            label: 'Too much',
                            color: kRed,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    // Show reason section only if a level is selected
                    if (_selectedLevel != null) ...[
                      const SizedBox(height: 32),
                      
                      // Reason label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            'REASON',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: kTextSecondary,
                            ),
                          ),
                        ),
                      ),
                      
                      // Reason options
                      ..._reasons.map((reason) {
                        final isSelected = _selectedReason == reason;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedReason = reason;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kPrimaryBlue.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? kPrimaryBlue.withValues(alpha: 0.3)
                                      : (isDark ? kBorderDark : const Color(0xFFE5E5EA)),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? kPrimaryBlue
                                          : (isDark 
                                              ? const Color(0xFFD1D5DB) 
                                              : const Color(0xFF374151)),
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? kPrimaryBlue
                                            : (isDark 
                                                ? const Color(0xFF525252) 
                                                : const Color(0xFFD1D5DB)),
                                        width: 2,
                                      ),
                                      color: isSelected ? kPrimaryBlue : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    const SizedBox(height: 32),
                    
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
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kTextSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _selectedLevel != null
                                ? () {
                                    // TODO: Save decision review data
                                    Navigator.pop(context, {
                                      'level': _selectedLevel,
                                      'reason': _selectedReason,
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
                              shadowColor: kPrimaryBlue.withValues(alpha: 0.2),
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
      ),
    );
  }

  Widget _buildLevelButton({
    required DecisionLevel level,
    required String symbol,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedLevel == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
          // Reset reason when changing level
          if (!isSelected) {
            _selectedReason = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.05)
              : (isDark ? kCardDark : Colors.white),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : (isDark ? kBorderDark : const Color(0xFFE5E5EA)),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 32,
                color: isSelected
                    ? color
                    : (isDark 
                        ? const Color(0xFF6B7280) 
                        : const Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark 
                        ? const Color(0xFF9CA3AF) 
                        : const Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

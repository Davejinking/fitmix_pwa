import 'package:flutter/material.dart';

class ReflectionOnboardingOverlay extends StatelessWidget {
  const ReflectionOnboardingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Stack(
          children: [
            // Main message
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'IronLog lets you record context when it matters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You can add it anytime, or not at all.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE5E7EB),
                        height: 1.4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tap to continue hint
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.4, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  onEnd: () {
                    // Restart animation
                  },
                  child: Text(
                    'TAP TO CONTINUE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: Colors.white.withValues(alpha: 0.6),
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
}

import 'package:flutter/material.dart';

class FMBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FMBottomNavItem> items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;

  const FMBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF0A0A0A),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1), // Subtle top border
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildNavItem(
              index,
              item.activeIcon,
              item.icon,
              item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final bool isSelected = currentIndex == index;
    final Color activeColor = selectedItemColor ?? const Color(0xFF3B82F6);
    final Color inactiveColor = unselectedItemColor ?? const Color(0xFF52525B);

    // Detect if label contains non-ASCII characters (Japanese/Korean)
    final bool isAsianLanguage = label.runes.any((rune) => rune > 127);
    final double letterSpacing = isAsianLanguage ? 0.0 : 0.8;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with Neon Glow if selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: isSelected
                    ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.6),
                            blurRadius: 15,
                            spreadRadius: -2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? Colors.white : inactiveColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label text
              Text(
                isAsianLanguage ? label : label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: letterSpacing,
                  fontFamily: 'Courier',
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FMBottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  FMBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

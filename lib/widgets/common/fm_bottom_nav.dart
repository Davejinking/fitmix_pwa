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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: selectedItemColor ?? const Color(0xFF007AFF), // 스카이 블루
      unselectedItemColor: unselectedItemColor ?? const Color(0xFF8E8E93), // 어두운 회색
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: backgroundColor ?? const Color(0xFF1E1E1E),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: items.map((item) {
        final index = items.indexOf(item);
        final isSelected = currentIndex == index;
        
        return BottomNavigationBarItem(
          icon: Icon(
            isSelected ? item.activeIcon : item.icon,
            size: 24,
          ),
          label: item.label,
        );
      }).toList(),
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

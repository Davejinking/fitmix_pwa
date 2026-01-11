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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Pure black void
        border: Border(
          top: BorderSide(
            color: Colors.white24, // 🔥 Tactical border
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: selectedItemColor ?? Colors.white, // 🔥 Active: Bright White
        unselectedItemColor: unselectedItemColor ?? Colors.grey[600], // 🔥 Inactive: Dark Grey
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // No shadow
        backgroundColor: Colors.black, // Pure black
        selectedFontSize: 11, // 🔥 Tactical font size
        unselectedFontSize: 10, // 🔥 Smaller when inactive
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700, // 🔥 Bold when active
          fontFamily: 'Courier',
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: 'Courier',
          letterSpacing: 0.5,
        ),
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

import 'package:flutter/material.dart';

/// Global Standard AppBar for Iron Log
/// Enforces consistent branding across all tabs
class IronAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const IronAppBar({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Pure black void
      elevation: 0, // No shadow
      centerTitle: false, // Left aligned
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: const Text(
        'IRON LOG',
        style: TextStyle(
          fontSize: 30,
          letterSpacing: 2.0,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontFamily: 'Courier', // Monospace tactical font
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

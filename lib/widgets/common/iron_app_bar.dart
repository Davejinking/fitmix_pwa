import 'package:flutter/material.dart';

/// Global Standard AppBar for Iron Log
/// Enforces consistent branding across all tabs
class IronAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final String? title;

  const IronAppBar({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Pure black void
      elevation: 0, // No shadow
      centerTitle: false, // Left aligned
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title ?? 'IRON LOG',
        style: TextStyle(
          fontSize: title != null ? 18 : 30,
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

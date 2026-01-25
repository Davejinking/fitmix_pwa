import 'package:flutter/material.dart';

/// Global Standard AppBar for Iron Log
/// Enforces consistent branding across all tabs
class IronAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final String? title;
  final TextStyle? titleStyle;

  const IronAppBar({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.title,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Pure black void
      elevation: 0, // No shadow
      centerTitle: true, // 🔥 Center aligned for Tactical Library style
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title ?? 'IRON LOG',
        style: titleStyle ?? TextStyle(
          fontSize: title != null ? 18 : 20,
          letterSpacing: 3.0, // 🔥 Wider spacing
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

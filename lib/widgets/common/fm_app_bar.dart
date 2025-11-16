import 'package:flutter/material.dart';
import '../../core/burn_fit_style.dart';

class FMAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final bool showNotificationIcon;
  final bool showProfileIcon;
  final bool showSettingsIcon;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final List<Widget>? actions;

  const FMAppBar({
    super.key,
    required this.title,
    this.showNotificationIcon = false,
    this.showProfileIcon = false,
    this.showSettingsIcon = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSettingsTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: title is String
          ? Text(
              title as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BurnFitStyle.darkGrayText,
              ),
            )
          : title,
      actions: [
        if (actions != null) ...actions!,
        if (showNotificationIcon)
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 24),
            onPressed: onNotificationTap,
            color: BurnFitStyle.darkGrayText,
          ),
        if (showProfileIcon)
          IconButton(
            icon: const Icon(Icons.person_outline, size: 24),
            onPressed: onProfileTap,
            color: BurnFitStyle.darkGrayText,
          ),
        if (showSettingsIcon)
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            onPressed: onSettingsTap,
            color: BurnFitStyle.darkGrayText,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

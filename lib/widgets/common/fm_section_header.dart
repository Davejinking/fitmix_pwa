import 'package:flutter/material.dart';
import '../../core/burn_fit_style.dart';

class FMSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final Widget? trailing;

  const FMSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BurnFitStyle.darkGrayText,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionText != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 14,
                  color: BurnFitStyle.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

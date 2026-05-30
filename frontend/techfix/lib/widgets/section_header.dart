import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                letterSpacing: -0.2,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 9),
              Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.faint,
                ),
              ),
            ],
          ],
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actionIcon != null) Icon(actionIcon, size: 18, color: AppTheme.coral),
                if (actionIcon != null) const SizedBox(width: 5),
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.coral,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

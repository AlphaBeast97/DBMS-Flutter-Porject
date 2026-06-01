/// Small rounded pill/chip wrapper for tags and labels.
///
/// Renders [child] text inside a horizontally-padded rounded container
/// with an optional leading [icon]. [color] controls the text/icon tint
/// and the default background opacity; pass [bg] for a solid color.
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class Pill extends StatelessWidget {
  final Color color;
  final Color? bg;
  final IconData? icon;
  final Widget child;

  const Pill({
    super.key,
    this.color = AppTheme.ink,
    this.bg,
    this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

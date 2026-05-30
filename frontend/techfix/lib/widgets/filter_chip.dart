import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.count,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color : AppTheme.line2,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: active ? color : AppTheme.ink,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: active ? color : AppTheme.muted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

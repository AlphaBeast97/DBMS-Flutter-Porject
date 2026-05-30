import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color accent;
  final String? sub;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent = AppTheme.teal,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              if (icon != null)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 7),
            Text(
              sub!,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.faint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge that displays a job status with its associated color and icon.
///
/// Uses [AppTheme]'s status helpers ([statusBg], [statusColor],
/// [statusIcon], [statusLabel]) to render a compact pill.
/// [sm] reduces the size for tighter layouts.
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool sm;

  const StatusBadge({super.key, required this.status, this.sm = false});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sm ? 9 : 11, vertical: sm ? 3 : 5),
      decoration: BoxDecoration(
        color: AppTheme.statusBg(s),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppTheme.statusIcon(s), size: sm ? 13 : 15, color: AppTheme.statusColor(s)),
          const SizedBox(width: 5),
          Text(
            AppTheme.statusLabel(s),
            style: TextStyle(
              fontSize: sm ? 11.5 : 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.statusColor(s),
            ),
          ),
        ],
      ),
    );
  }
}

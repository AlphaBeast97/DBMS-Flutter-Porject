import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.color = AppTheme.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 54),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 38, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              
              fontSize: 14,
              color: AppTheme.muted,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

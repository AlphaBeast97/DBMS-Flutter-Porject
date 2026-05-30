import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.body = "We couldn't reach the server. Check your connection and try again.",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppTheme.coral.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.cloud_off, size: 38, color: AppTheme.coral),
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
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.coral,
                side: const BorderSide(color: AppTheme.coral),
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

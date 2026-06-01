/// Circular avatar that shows a person's initials or an icon.
///
/// Derives initials from the first two words of [name]. Falls back to
/// a question mark if the name is empty. Optionally renders an [icon]
/// instead of initials.
import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final IconData? icon;

  const Avatar({
    super.key,
    required this.name,
    this.size = 40,
    this.color = AppTheme.teal,
    this.icon,
  });

  String get _initials {
    final parts = (name.isNotEmpty ? name : '?').split(' ');
    return parts.take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: size * 0.5, color: color)
            : Text(
                _initials,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.36,
                  color: color,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.94, -0.34),  // 160° angle
              end: Alignment(0.94, 0.34),
              colors: [AppTheme.cream, Color(0xFFF1E9DB), AppTheme.beige],
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: -60,
          child: _GlowCircle(size: 240, color: AppTheme.coral.withOpacity(0.16)),
        ),
        Positioned(
          top: 180,
          right: 260,
          child: _GlowCircle(size: 220, color: AppTheme.teal.withOpacity(0.13)),
        ),
        Positioned(
          top: 560,
          left: -80,
          child: _GlowCircle(size: 280, color: AppTheme.sky.withOpacity(0.10)),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

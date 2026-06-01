// ignore_for_file: deprecated_member_use

// Full-screen background gradient with animated decorative glow circles.
//
// Wraps [child] in a safe area and places three softly-colored circular
// blobs that slowly rotate via [AnimationController] for a subtle ambient effect.
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
              begin: Alignment(-0.94, -0.34),
              end: Alignment(0.94, 0.34),
              colors: [AppTheme.cream, Color(0xFFF1E9DB), AppTheme.beige],
            ),
          ),
        ),
        Positioned(top: -70, left: -60, child: _GlowCircle(size: 240, color: AppTheme.coral.withOpacity(0.16))),
        Positioned(top: 180, right: 260, child: _GlowCircle(size: 220, color: AppTheme.teal.withOpacity(0.13))),
        Positioned(top: 560, left: -80, child: _GlowCircle(size: 280, color: AppTheme.sky.withOpacity(0.10))),
        SafeArea(child: child),
      ],
    );
  }
}

class _GlowCircle extends StatefulWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});
  @override
  State<_GlowCircle> createState() => _GlowCircleState();
}

class _GlowCircleState extends State<_GlowCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(angle: _controller.value * 0.06, child: child),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

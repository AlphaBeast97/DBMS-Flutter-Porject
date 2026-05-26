import 'package:flutter/material.dart';

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDF8F2),
                Color(0xFFF6EBDD),
              ],
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -40,
          child: _GlowCircle(size: 180, color: Color(0x33F26B4A)),
        ),
        Positioned(
          bottom: -80,
          left: -20,
          child: _GlowCircle(size: 220, color: Color(0x332A9D8F)),
        ),
        Positioned(
          top: 200,
          left: -50,
          child: _GlowCircle(size: 140, color: Color(0x223D7BD1)),
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

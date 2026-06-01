/// Staggered entrance animation for list items.
///
/// Fades in and slides up slightly. Accepts [delayMs] for cascading
/// animations when rendering multiple items in a list.
import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const FadeIn({super.key, required this.child, this.delayMs = 0});
  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    if (widget.delayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: widget.child,
      ),
    );
  }
}

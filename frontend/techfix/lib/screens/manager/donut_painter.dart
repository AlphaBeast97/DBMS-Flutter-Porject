import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class DonutPainter extends CustomPainter {
  final List<({Color color, double count})> segments;

  DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const thickness = 22.0;
    final total = segments.fold<double>(0, (s, seg) => s + seg.count);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = AppTheme.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -1.5708;
    for (final seg in segments) {
      final sweepAngle = (seg.count / total) * 6.28319;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle.clamp(0.001, 6.28319), false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) => segments != old.segments;
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppTheme.muted,
          ),
        ),
      ],
    );
  }
}

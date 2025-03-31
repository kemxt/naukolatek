import 'dart:math' as math;
import 'package:flutter/material.dart';

class PieChartPainter extends CustomPainter {
  final double totalExpenses;
  final double budget;
  final double height;
  final double animationValue;

  PieChartPainter({
    required this.totalExpenses,
    required this.budget,
    required this.height,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Calculate the percentage used
    double percentageUsed = (totalExpenses / budget);
    if (percentageUsed > 1.0) percentageUsed = 1.0;

    // For animation, we'll animate the sweep angle
    final sweepAngle = 2 * math.pi * percentageUsed * animationValue;

    // Choose color based on percentage used
    final color = _getColorForPercentage(percentageUsed);

    // Create gradient for a more polished look
    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [
        color.withOpacity(0.7),
        color,
        color.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Draw chart section
    final chartPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: center,
        radius: radius,
      ))
      ..style = PaintingStyle.fill;

    // Start from top (12 o'clock position)
    const startAngle = -math.pi / 2;

    // Draw sector
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      chartPaint,
    );

    // Add a subtle stroke
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, strokePaint);

    // Add incremental indicators around the circle (tick marks)
    _drawTickMarks(canvas, center, radius);

    // Add highlight effect at the edge
    if (animationValue > 0.5) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2 * (animationValue - 0.5) * 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        false,
        highlightPaint,
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.2 * animationValue)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      final startPoint = Offset(
        center.dx + (radius - 2) * math.cos(angle),
        center.dy + (radius - 2) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 0.9) {
      return Colors.red.shade400;
    } else if (percentage >= 0.7) {
      return Colors.orange.shade400;
    } else if (percentage >= 0.5) {
      return Colors.yellow.shade400;
    } else {
      return Colors.green.shade400;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.totalExpenses != totalExpenses ||
        oldDelegate.budget != budget ||
        oldDelegate.height != height ||
        oldDelegate.animationValue != animationValue;
  }
}

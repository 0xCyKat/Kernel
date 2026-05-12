import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double? maxY;
  final double? minY;

  SparklinePainter({
    required this.data,
    required this.color,
    this.maxY,
    this.minY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data.length == 1) return;

    final double maxVal = maxY ?? (data.reduce((a, b) => a > b ? a : b));
    final double minVal = minY ?? (data.reduce((a, b) => a < b ? a : b));

    // Safety buffer if max == min
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final Paint linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    final double xStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      // Invert Y because canvas Y grows downwards
      final double normalizedY = (data[i] - minVal) / range;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the gradient fill area
    final Path areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}


import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Sparkline extends StatelessWidget {
  final List<double> values;
  const Sparkline({super.key, required this.values});
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(double.infinity, 48),
    painter: _SparkPainter(values));
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  _SparkPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    final dx = size.width / (values.length - 1);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final glow = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.25)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final line = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant _SparkPainter o) => o.values != values;
}

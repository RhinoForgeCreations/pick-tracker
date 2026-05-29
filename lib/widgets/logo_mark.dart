import 'package:flutter/material.dart';

/// The Pick Tracker glyph: three ascending bars with a rising arrow,
/// matching the app icon. Painted inside a square of [size].
class LogoMark extends StatelessWidget {
  final double size;
  final Color color;
  const LogoMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter(color)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final Color color;
  _GlyphPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..color = color..isAntiAlias = true;

    final bw = s * 0.150;
    final gap = s * 0.040;
    final baseY = s * 0.760;
    const heights = [0.215, 0.360, 0.510];
    final groupW = bw * 3 + gap * 2;
    final startX = (s - groupW) / 2;
    final rr = Radius.circular(bw * 0.30);

    for (var i = 0; i < heights.length; i++) {
      final bh = s * heights[i];
      final x0 = startX + i * (bw + gap);
      final y0 = baseY - bh;
      canvas.drawRRect(
        RRect.fromLTRBR(x0, y0, x0 + bw, baseY, rr),
        paint,
      );
    }

    // Rising arrow over the tallest (3rd) bar.
    final tipX = startX + 2 * (bw + gap) + bw / 2;
    final tipTop = s * 0.205;
    final a = bw;
    final arrow = Path()
      ..moveTo(tipX, tipTop)
      ..lineTo(tipX + a * 0.62, tipTop + a * 0.62)
      ..lineTo(tipX + a * 0.22, tipTop + a * 0.62)
      ..lineTo(tipX + a * 0.22, tipTop + a * 1.15)
      ..lineTo(tipX - a * 0.22, tipTop + a * 1.15)
      ..lineTo(tipX - a * 0.22, tipTop + a * 0.62)
      ..lineTo(tipX - a * 0.62, tipTop + a * 0.62)
      ..close();
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

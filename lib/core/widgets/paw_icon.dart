import 'package:flutter/material.dart';

/// A rounded paw print drawn in code, so the center button does not depend
/// on the Material icon font.
class PawIcon extends StatelessWidget {
  const PawIcon({this.size = 24, this.color = Colors.white, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PawPainter(color));
  }
}

class _PawPainter extends CustomPainter {
  const _PawPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.66),
          width: w * 0.50,
          height: h * 0.36,
        ),
        Radius.circular(w * 0.18),
      ),
      paint,
    );
    final toes = <Offset>[
      Offset(w * 0.24, h * 0.40),
      Offset(w * 0.40, h * 0.26),
      Offset(w * 0.60, h * 0.26),
      Offset(w * 0.76, h * 0.40),
    ];
    for (final toe in toes) {
      canvas.drawOval(
        Rect.fromCenter(center: toe, width: w * 0.18, height: h * 0.22),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PawPainter oldDelegate) =>
      oldDelegate.color != color;
}

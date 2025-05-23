import 'package:flutter/material.dart';

class OvalsPainterHome extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Usa el tamaño real de la pantalla, no uno fijo.
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFEA1D5D),
        Color(0xFF2E1F54),
        Color(0xFF050F2C),
      ],
    ).createShader(rect);

    final path = Path();
    path.lineTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.4,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.2,
      size.width, size.height * 0.3,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

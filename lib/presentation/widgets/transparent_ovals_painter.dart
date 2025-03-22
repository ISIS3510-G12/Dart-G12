import 'package:flutter/material.dart';

class TransparentOvalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    List<Color> colors = [
      const Color(0xFFEA1D5D).withOpacity(0.5),
      const Color(0xFF2E1F54).withOpacity(0.5),
      const Color(0xFF050F2C).withOpacity(0.5),
    ];
    List<double> yPositions = [-25, -75, -115];
    List<double> rotations = [0, 0, 0.4];

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.save();
      canvas.translate(size.width / 2, yPositions[i]);
      canvas.rotate(rotations[i]);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 0), width: 504, height: 418),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

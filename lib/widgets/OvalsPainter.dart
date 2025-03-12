import 'package:flutter/material.dart';

// Clase para dibujar los círculos
class OvalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    List<Color> colors = [ const Color(0xFFEA1D5D), const Color(0xFF2E1F54),const Color(0xFF050F2C)];
    List<double> yPositions = [-25,-75,-115];
    List<double> rotations = [0, 0, 0.4]; // Ángulos de rotación en radianes
    List<double> opacities = [1.0, 1.0, 1.0]; // Opacidad al máximo para evitar mezcla
    
    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(opacities[i]);
      canvas.save();
      canvas.translate(size.width / 2, yPositions[i]);
      canvas.rotate(rotations[i]);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, 0), width: 504, height: 418), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

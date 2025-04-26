import 'package:flutter/material.dart';


class OvalsPainterHome extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final fixedWidth = 420.0;  
    final fixedHeight = 765.0;  
    final paint = Paint()..style = PaintingStyle.fill;


    final Rect rect = Rect.fromLTWH(0, 0, fixedWidth, fixedHeight);
    

    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFEA1D5D), 
        const Color(0xFF2E1F54), 
        const Color(0xFF050F2C), 
      ],
    );

    paint.shader = gradient.createShader(rect);

    final path = Path();
    path.lineTo(0, fixedHeight * 0.25); 
    path.quadraticBezierTo(
      fixedWidth * 0.2, fixedHeight * 0.4, 
      fixedWidth * 0.5, fixedHeight * 0.3,
    );
    path.quadraticBezierTo(
      fixedWidth * 0.8, fixedHeight * 0.2, 
      fixedWidth, fixedHeight * 0.3,
    );
    path.lineTo(fixedWidth, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


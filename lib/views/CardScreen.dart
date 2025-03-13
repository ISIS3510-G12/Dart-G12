import 'package:flutter/material.dart';
import '../widgets/OvalsPainter.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con los círculos superpuestos
          Positioned.fill(
            child: CustomPaint(
              painter: OvalsPainter(),
            ),
          ),

          // Contenido principal
          const Center(
            child: Text(
              'Card Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
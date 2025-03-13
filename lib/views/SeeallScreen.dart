import 'package:flutter/material.dart';
import '../widgets/OvalsPainter.dart';

class SeeallScreen extends StatelessWidget {
  const SeeallScreen({super.key});

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
              'See all',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/OvalsPainter.dart';

class CardScreen extends StatelessWidget {
  final int buildingIndex;
  const CardScreen({super.key, required this.buildingIndex});

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
              'Card Screen Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/chat_widget.dart'; // Asegúrate de que la ruta sea correcta

class Pagina2 extends StatelessWidget {
  const Pagina2({super.key});

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
          Column(
            children: [
              const Center(
                child: Text(
                  'Página 2',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: ChatWidget()), // Agregamos el ChatWidget aquí
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/OvalsPainter.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  _Pagina1State createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Hi, Juan', style: TextStyle(color: Colors.white, 
        fontSize: 28, fontFamily: 'Inter', 
        fontWeight: FontWeight.w600)), // Texto a la izquierda
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0), // Espaciado derecho
            child: ClipOval(
            child: Image.asset(
              'assets/icon.jpg',
              width: 55, 
              height: 55,
              fit: BoxFit.cover, 
            ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: OvalsPainter(),
            ),
          ),
          const Center(
            child: Text(
              'Página 1',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

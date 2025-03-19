import 'package:flutter/material.dart';
import '../widgets/OvalsPainter.dart';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

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

          // Título "Buildings" sobre el fondo
          Positioned(
            top: 50,  // Ajusta la distancia desde la parte superior si es necesario
            left: MediaQuery.of(context).size.width / 2 - 90,  // Centra el texto
            child: Text(
              "Buildings",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Contenido principal con desplazamiento para evitar overflow
          Expanded(  // Asegura que el contenido restante ocupe el espacio disponible
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 120), // Espacio ajustado para no sobreponer el título
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de búsqueda con fondo blanco y texto negro
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Where to go?",
                          labelStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white, // Fondo blanco
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.filter_alt_outlined),
                        ),
                      ),
                    ),

                    // Espacio entre la búsqueda y la cuadrícula
                    const SizedBox(height: 20),

                    // Cuadrícula de edificios
                    GridView.count(
                      crossAxisCount: 2, // Dos columnas para la cuadrícula
                      crossAxisSpacing: 16.0, // Espaciado entre columnas
                      mainAxisSpacing: 16.0, // Espaciado entre filas
                      padding: const EdgeInsets.all(16.0),
                      shrinkWrap: true, // Evitar el error de overflow
                      //physics: NeverScrollableScrollPhysics(),  Deshabilitar el desplazamiento de la cuadrícula
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            // Aquí se manejaría la navegación a la pantalla de detalles
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CardScreen(buildingIndex: index),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                // Aquí se agregarán las imágenes cuando tengas los assets
                                Container(
                                  height: 120,
                                  color: Colors.grey[300], // Usado como placeholder por ahora
                                  child: Icon(Icons.image, size: 50), // Placeholder
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Bloque ${['ML', 'W', 'SD', 'O', 'C'][index]}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Edificio ${['Mario Laserna', 'Facultad de Economía', 'Julián Mario Santo Domingo', 'Henri Yeri', 'Facultad de Diseño'][index]}',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder CardScreen to navigate to when tapping on a building
class CardScreen extends StatelessWidget {
  final int buildingIndex;

  const CardScreen({super.key, required this.buildingIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Building Details')),
      body: Center(
        child: Text(
          'Details for Building ${['ML', 'W', 'SD', 'O', 'C'][buildingIndex]}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

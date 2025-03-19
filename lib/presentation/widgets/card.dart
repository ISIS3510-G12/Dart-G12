import 'package:flutter/material.dart';
import '../../widgets/OvalsPainter.dart';

class CardScreen extends StatelessWidget {
  final int buildingIndex;

  // Recibimos el índice del edificio
  const CardScreen({super.key, required this.buildingIndex});

  @override
  Widget build(BuildContext context) {
    // Datos de los edificios
    final buildingNames = ['ML', 'W', 'SD', 'O', 'C'];
    final buildingDetails = [
      'Mario Laserna',
      'Facultad de Economía',
      'Julián Mario Santo Domingo',
      'Henri Yeri',
      'Facultad de Diseño'
    ];
    final buildingImages = [
      'assets/images/ml_image.jpg',
      'assets/images/w_image.jpg',
      'assets/images/sd_image.jpg',
      'assets/images/o_image.jpg',
      'assets/images/c_image.jpg'
    ];

    // Datos de lugares populares (genéricos)
    final popularPlaces = [
      {'name': 'Lugar 1', 'location': 'Ubicación 1'},
      {'name': 'Lugar 2', 'location': 'Ubicación 2'},
      {'name': 'Lugar 3', 'location': 'Ubicación 3'},
      {'name': 'Lugar 4', 'location': 'Ubicación 4'},
    ];

    // Obtén los detalles del edificio seleccionado
    String buildingName = buildingNames[buildingIndex];
    String buildingDetail = buildingDetails[buildingIndex];
    String buildingImage = buildingImages[buildingIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Imagen del edificio
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(buildingImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fondo con los círculos superpuestos
          Positioned.fill(
            child: CustomPaint(
              painter: OvalsPainter(),
            ),
          ),

          // Título "Bloque XX" centrado en el eje X
          Positioned(
            top: 50,  // Ajusta la distancia desde la parte superior si es necesario
            left: MediaQuery.of(context).size.width / 2 - 90,  // Centra el texto
            child: Text(
              'Bloque $buildingName',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.transparent,
                  color: Colors.white
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contenido principal
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0), // Ajustar para no sobreponer el título
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botones: Indicaciones y Añadir a Favoritos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.directions),
                          label: Text('Indicaciones'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEA1D5D),
                              foregroundColor: Colors.white,
                              iconColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border),
                          label: Text('Añadir a Favoritos'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEA1D5D),
                              foregroundColor: Colors.white,
                              iconColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lugares Populares con scroll lateral
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Lugares Populares',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularPlaces.length,
                      itemBuilder: (context, index) {
                        var place = popularPlaces[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(right: 16.0),
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 80,
                                  color: Colors.grey[300], // Placeholder for image
                                  child: Icon(Icons.place, size: 50), // Placeholder icon
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  place['name']!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(place['location']!),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/card_view_model.dart';
import '../widgets/transparent_ovals_painter.dart';
import '../widgets/place_card.dart';

class CardScreen extends StatefulWidget {
  final int buildingId;

  const CardScreen({super.key, required this.buildingId});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CardViewModel>(context, listen: false)
          .fetchBuildingDetails(widget.buildingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CardViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // ** Imagen del edificio**
          Positioned(
            top: 0, // 🔹 Ajusta la posición para que la imagen empiece más arriba
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(viewModel.building?['image_url'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Fondo con OvalsPainter Transparente (Encima de la Imagen)
          Positioned.fill(child: CustomPaint(painter: TransparentOvalsPainter())),

          // **Nombre del Bloque (centrado y encima del oval)**
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Text(
              '${viewModel.building?['name'] ?? ''}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // **Contenido principal**
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.error != null)
            Center(child: Text(viewModel.error!))
          else if (viewModel.building != null) ...[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 270), // 🔹 Espacio extra para que la imagen no se superponga con los elementos

                    // ** Botones: Indicaciones y Añadir a Favoritos**
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.directions, size: 20),
                            label: const Text('Cómo llegar', style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA1D5D),
                              foregroundColor: Colors.white,
                              iconColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border, size: 20),
                            label: const Text('Favoritos', style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA1D5D),
                              foregroundColor: Colors.white,
                              iconColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ** Barra de búsqueda**
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Where to go?",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ** Lugares Populares**
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Lugares Populares',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ** Lista de Lugares**
                    SizedBox(
                      height: 150,
                      child: viewModel.places.isNotEmpty
                          ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.places.length,
                        itemBuilder: (context, index) {
                          final place = viewModel.places[index];
                          return PlaceCard(
                            imagePath: place['url_image'] ?? '',
                            title: place['name'],
                            subtitle: 'Piso: ${place['floor']}',
                          );
                        },
                      )
                          : const Center(child: Text("No hay lugares disponibles")),
                    ),
                  ],
                ),
              ),
            ]
        ],
      ),
    );
  }
}

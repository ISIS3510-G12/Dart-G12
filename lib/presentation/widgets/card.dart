import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/card_view_model.dart';
import '../widgets/OvalsPainter.dart';
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
          // **1️⃣ Fondo con OvalsPainter**
          Positioned.fill(child: CustomPaint(painter: OvalsPainter())),

          // **2️⃣ Nombre del Bloque (centrado y encima del oval)**
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

          // **3️⃣ Contenido principal**
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.error != null)
            Center(child: Text(viewModel.error!))
          else if (viewModel.building != null) ...[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 185), // 🔹 Espacio adicional para que la imagen no toque el oval

                    // **4️⃣ Imagen del edificio (sin bordes redondeados)**
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(viewModel.building!['image_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // **5️⃣ Botones: Indicaciones y Añadir a Favoritos**
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          // Botón de Indicaciones
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
                          const SizedBox(width: 12), // Espacio entre botones
                          // Botón de Añadir a Favoritos
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

                    // **6️⃣ Barra de búsqueda**
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

                    // **7️⃣ Lugares Populares**
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Lugares Populares',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // **8️⃣ Lista de Lugares**
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

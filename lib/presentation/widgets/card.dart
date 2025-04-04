import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/card_view_model.dart';
import '../widgets/transparent_ovals_painter.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';  // Asumiendo que tienes un widget BottomNavbar
import 'package:dart_g12/presentation/views/map_page.dart'; // Asegúrate de que MapPage esté correctamente importada

class CardScreen extends StatefulWidget {
  final int buildingId;

  const CardScreen({super.key, required this.buildingId});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late CardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CardViewModel();
    _fetchBuildingDetails();
  }

  Future<void> _fetchBuildingDetails() async {
    await viewModel.fetchBuildingDetails(widget.buildingId);
    setState(() {}); // Actualizamos el estado después de obtener los datos
  }

  void _onItemTapped(int index) {
    viewModel.updateSelectedIndex(index);
  }

  // Función para navegar al mapa
  void _goToMapPage(BuildContext context) {
    viewModel.goToMapPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen del edificio
          Positioned(
            top: 0,
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

          // Nombre del Bloque (centrado y encima del oval)
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

          // Contenido principal
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.building == null)
            const Center(child: Text("Building could not be loaded"))
          else ...[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 270), // Espacio para la imagen

                  // Botones: Indicaciones y Añadir a Favoritos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _goToMapPage(context),  // Llamada a la función para navegar al mapa
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text('How to get there', style: TextStyle(fontSize: 14)),
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
                          label: const Text('Favorites', style: TextStyle(fontSize: 14)),
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

                  // Barra de búsqueda
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

                  // Lugares Populares
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Popular Places',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lista de Lugares
                  SizedBox(
                    height: 165,
                    child: viewModel.places.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: viewModel.places.length,
                            itemBuilder: (context, index) {
                              final place = viewModel.places[index];
                              return PlaceCard(
                                imagePath: place['url_image'] ?? '',
                                title: place['name'],
                                subtitle: 'Floor: ${place['floor']}',
                              );
                            },
                          )
                        : const Center(child: Text("No places available")),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

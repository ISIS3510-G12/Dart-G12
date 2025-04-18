import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_g12/presentation/view_models/card_view_model.dart';
import '../widgets/transparent_ovals_painter.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';

class CardScreen extends StatefulWidget {
  final int buildingId;

  const CardScreen({super.key, required this.buildingId});

  @override
  CardScreenState createState() => CardScreenState();
}

class CardScreenState extends State<CardScreen> {
  late CardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CardViewModel();
    _fetchBuildingDetails();
  }

  Future<void> _fetchBuildingDetails() async {
    await viewModel.fetchBuildingDetails(widget.buildingId);
    if (mounted) setState(() {});
  }

  ImageProvider _getImageProvider(CardViewModel viewModel) {
    final imageUrl = viewModel.building?['image_url'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(imageUrl);
    } else {
      return const AssetImage('assets/images/default_image.jpg');
    }
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
                  image: _getImageProvider(viewModel),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Fondo con OvalsPainter Transparente (encima de la imagen)
          Positioned.fill(
            child: CustomPaint(painter: TransparentOvalsPainter()),
          ),

          // Nombre del bloque (centrado)
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

                  // Botones: Indicaciones y Favoritos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => viewModel.goToMapPage(context),
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text('How to get there'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA1D5D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border, size: 20),
                          label: const Text('Favorites'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA1D5D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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

                  // Título
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Popular Places',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Lista horizontal de lugares
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
          ],
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: (index) => viewModel.onItemTapped(context, index),
      ),
    );
  }
}

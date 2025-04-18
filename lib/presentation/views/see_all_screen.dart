import 'package:flutter/material.dart';
import '../view_models/see_all_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/place_card.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/card.dart';
import '../widgets/card_event.dart';

class SeeAllScreen extends StatefulWidget {
  final int initialIndex;
  final String contentType;  // Puede ser "building" o "event"

  const SeeAllScreen({super.key, this.initialIndex = 0, required this.contentType});

  @override
  SeeAllScreenState createState() => SeeAllScreenState();
}

class SeeAllScreenState extends State<SeeAllScreen> {
  late SeeAllViewModel _viewModel;
  

  @override
  void initState() {
    super.initState();
    _viewModel = SeeAllViewModel();
    _viewModel.contentType = widget.contentType;  // Asignar el contentType
    _viewModel.addListener(_updateState);

    // Cargar los datos basados en contentType
    if (widget.contentType == "building") {
      _viewModel.fetchBuildings();  // Fetch edificios
    } else if (widget.contentType == "event") {
      _viewModel.fetchEvents();  // Fetch eventos
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título dinámico basado en el contentType
                  Center(
                    child: Text(
                      widget.contentType == "building" ? "Buildings" : "Events",  // Cambiar título según el tipo
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Barra de búsqueda
                  TextField(
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
                  const SizedBox(height: 16),

                  // Cargar contenido dinámico
                  Expanded(
                    child: _viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _viewModel.error != null
                            ? Center(child: Text(_viewModel.error!))
                            : _viewModel.items.isEmpty
                                ? Center(child: Text("No hay ${widget.contentType}s disponibles"))
                                : SingleChildScrollView(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 600),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: _viewModel.items.map((item) {
                                            return PlaceCard(
                                              imagePath: item['image_url'] ?? 'assets/images/default_image.jpg',
                                              title: item['title'] ?? item['name'] ?? 'Unknown ${widget.contentType}',
                                              onTap: () {
                                                if (widget.contentType == "building") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CardScreen(buildingId: item['location_id']),
                                                    ),
                                                  );
                                                } else if (widget.contentType == "event") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CardEvent(eventId: item['event_id']),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _viewModel.selectedIndex,
        onTap: (index) => _viewModel.onItemTapped(context, index),
      ),
    );
  }
}

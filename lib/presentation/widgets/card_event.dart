import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/event_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/place_card.dart'; // Usamos PlaceCard para mostrar detalles del evento
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart'; // Si tienes un BottomNavbar
import 'package:dart_g12/presentation/views/map_page.dart';

class CardEvent extends StatefulWidget {
  final int eventId;

  const CardEvent({super.key, required this.eventId});

  @override
  _CardEventState createState() => _CardEventState();
}

class _CardEventState extends State<CardEvent> {
  late EventViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EventViewModel();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    await viewModel.fetchEventDetails(widget.eventId);
    setState(() {}); // Actualizamos el estado después de obtener los datos
  }

  void _onItemTapped(int index) {
    viewModel.updateSelectedIndex(index);
  }

  // Función para navegar al mapa si es necesario
  void _goToMapPage(BuildContext context) {
    viewModel.goToMapPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen del evento
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(viewModel.event?['image_url'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Fondo con OvalsPainter Transparente (Encima de la Imagen)
          Positioned.fill(child: CustomPaint(painter: TransparentOvalsPainter())),

          // Nombre del Evento (centrado y encima del oval)
          Positioned(
            top: 280,
            left: 10,
            child: Text(
              '${viewModel.event?['title'] ?? ''}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Contenido principal
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.event == null)
            const Center(child: Text("Event could not be loaded"))
          else ...[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 320), // Espacio para la imagen


                    // Descripción del evento (solo si no está vacía)
                    if (viewModel.event?['description']?.isNotEmpty ?? false) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Description:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          viewModel.event?['description'] ?? 'No description available',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Fechas del evento (Start Time y End Time)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Event Dates:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Start Time: ${formatDateTime(viewModel.event?['start_time'] ?? '')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'End Time: ${formatDateTime(viewModel.event?['end_time'] ?? '')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Lista de Lugares
                    SizedBox(
                      height: 150,
                      child: viewModel.events.isNotEmpty
                          ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.events.length,
                        itemBuilder: (context, index) {
                          final place = viewModel.events[index];
                          return PlaceCard(
                            imagePath: place['url_image'] ?? '',
                            title: place['name'],
                            subtitle: 'Floor: ${place['floor']}',
                          );
                        },
                      )
                          : const Center(child: Text("")),
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

  // Función para formatear la fecha del evento
  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final String formattedDate = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      return formattedDate;
    } catch (e) {
      return 'Invalid date';
    }
  }
}

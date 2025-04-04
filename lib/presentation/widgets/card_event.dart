import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/event_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/place_card.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
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
    setState(() {});
  }

  void _onItemTapped(int index) {
    viewModel.updateSelectedIndex(index);
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
                image: viewModel.event != null && viewModel.event?['image_url'] != null
                    ? DecorationImage(
                  image: NetworkImage(viewModel.event?['image_url'] ?? ''),
                  fit: BoxFit.cover,
                )
                    : null, // Evita errores si la imagen no está disponible
                color: Colors.grey[300], // Fondo gris si no hay imagen
              ),
            ),
          ),

          // Fondo con OvalsPainter Transparente
          Positioned.fill(child: CustomPaint(painter: TransparentOvalsPainter())),

          // Cuerpo principal
          Positioned.fill(
            top: 280,
            child: viewModel.event == null
                ? const Center(child: CircularProgressIndicator()) // Mostramos "Cargando..."
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del evento
                    Text(
                      viewModel.event?['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Fechas del evento
                    if (viewModel.event?['start_time'] != null && viewModel.event?['end_time'] != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Dates:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '🕒 Start: ${formatDateTime(viewModel.event?['start_time'] ?? '')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '⏳ End: ${formatDateTime(viewModel.event?['end_time'] ?? '')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Descripción del evento
                    if (viewModel.event?['description']?.isNotEmpty ?? false) ...[
                      const Text(
                        'Description:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        viewModel.event?['description'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap:  (index) => viewModel.onItemTapped(context, index),
      ),
    );
  }


  // Función para formatear la fecha
  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}'
          ' ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

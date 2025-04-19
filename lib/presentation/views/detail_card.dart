import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/card_detail_view_model.dart';
import 'package:dart_g12/presentation/widgets/transparent_ovals_painter.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';


enum CardType {
  event,
  building,
  // Para agregar mas tipos a futuro
}

class DetailCard extends StatefulWidget {
  final int id;
  final CardType type; 

  const DetailCard({super.key, required this.id, required this.type});

  @override
  _DetailCardState createState() => _DetailCardState();
}



class _DetailCardState extends State<DetailCard> {
  late CombinedViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CombinedViewModel();
    _fetchDetails(); // Llama a una función general para manejar el tipo
  }

  // Función general para obtener los detalles según el tipo
  Future<void> _fetchDetails() async {
    switch (widget.type) {
      case CardType.event:
        await viewModel.fetchEventDetails(widget.id);
        break;
      case CardType.building:
        await viewModel.fetchBuildingDetails(widget.id);
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo (según el tipo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: widget.type == CardType.event ? 280 : 260,
              decoration: BoxDecoration(
                image: widget.type == CardType.event
                    ? (viewModel.event != null &&
                            viewModel.event?['image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(
                                viewModel.event?['image_url'] ?? ''),
                            fit: BoxFit.cover,
                          )
                        : null)
                    : widget.type == CardType.building
                        ? DecorationImage(
                            image: NetworkImage(
                                viewModel.building?['image_url'] ?? ''),
                            fit: BoxFit.cover,
                          )
                        : null, // Asegúrate de que aquí esté un "null" o el valor adecuado en caso de no ser un edificio.
                color: Colors.grey[300], // Fondo gris si no hay imagen
              ),
            ),
          ),

          // Fondo con OvalsPainter Transparente
          Positioned.fill(
              child: CustomPaint(painter: TransparentOvalsPainter())),

          // Cuerpo principal
          Positioned.fill(
            top: widget.type == CardType.event ? 280 : 260,
            child: widget.type == CardType.event
                ? viewModel.event == null
                    ? const Center(
                        child:
                            CircularProgressIndicator()) // Mostramos "Cargando..."
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
                              if (viewModel.event?['start_time'] != null &&
                                  viewModel.event?['end_time'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Event Dates:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
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
                              if (viewModel.event?['description']?.isNotEmpty ??
                                  false) ...[
                                const Text(
                                  'Description:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                      )
                // Agregar lógica similar para otros tipos (building, restaurant, etc.)
                : const Center(
                    child:
                        CircularProgressIndicator()), // Ejemplo de lógica para mostrar el contenido
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: viewModel.selectedIndex,
        onTap: (index) => viewModel.onItemTapped(context, index),
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

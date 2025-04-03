import 'package:flutter/material.dart';
import '../view_models/event_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../widgets/place_card.dart'; // Widget para mostrar un evento
import '../widgets/bottom_navbar.dart';
import '../views/main_screen.dart';

class EventScreen extends StatefulWidget {
  final int initialIndex;

  const EventScreen({super.key, this.initialIndex = 0});

  @override
  _SeeAllEventsScreenState createState() => _SeeAllEventsScreenState();
}

class _SeeAllEventsScreenState extends State<EventScreen> {
  late EventViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EventViewModel();
    _viewModel.fetchEvents();
    _viewModel.addListener(_updateState);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == _viewModel.selectedIndex) return;

    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }

  // Función para formatear la fecha de inicio (start_time) sin dependencias externas
  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final String formattedDate = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      return formattedDate;
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Text(
              "Events",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Events",
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
                  const SizedBox(height: 20),
                  Expanded(
                    child: _viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _viewModel.error != null
                        ? Center(child: Text(_viewModel.error!))
                        : _viewModel.events.isEmpty
                        ? const Center(child: Text("No events available"))
                        : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: _viewModel.events.length,
                      itemBuilder: (context, index) {
                        final event = _viewModel.events[index];
                        final formattedDate = formatDateTime(event['start_time']); // Formateamos la fecha
                        return GestureDetector(
                          onTap: () {
                            // Aquí puedes manejar la navegación al detalle del evento
                          },
                          child: PlaceCard(
                            imagePath: event['image_url'] ?? '',
                            title: event['title'],
                            subtitle: formattedDate, // Usamos la fecha formateada
                          ),
                        );
                      },
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
        onTap: _onItemTapped,
      ),
    );
  }
}

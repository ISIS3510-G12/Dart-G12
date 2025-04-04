import 'package:flutter/material.dart';
import '../../data/repositories/event_repository.dart';
import '../views/main_screen.dart';
import '../../data/services/analytics_service.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository repository = EventRepository();
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _event;  // Almacenará los detalles del evento
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  EventViewModel();

  /// Getters
  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get event => _event;  // Obtener detalles del evento
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  /// Método para obtener los eventos desde Supabase
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await repository.fetchEvents();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Método para obtener los detalles de un evento desde Supabase
  Future<void> fetchEventDetails(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Usamos el repository para obtener los detalles de un evento específico
      _event = await repository.fetchEventById(eventId);

      await AnalyticsService.logUserAction(
          actionType: 'consult_event',
          eventId: eventId,
          eventType: _event?['type'],
          title: _event?['title'],
          locationId: _event?['location_id']);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Método para actualizar el índice seleccionado y navegar a `MainScreen`
    void onItemTapped(BuildContext context, int index) {
    _selectedIndex = index;
    notifyListeners();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToMapPage(BuildContext context) {
    updateSelectedIndex(2);  // Índice 2 es para la página del mapa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)),
    );
  }
}

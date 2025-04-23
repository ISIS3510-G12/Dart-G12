import 'package:flutter/material.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../views/main_screen.dart';
import '../../data/services/analytics_service.dart';
import '../../data/repositories/laboratories_repository.dart';

class CardDetailViewModel extends ChangeNotifier {
  final EventRepository eventRepository = EventRepository();
  final LocationRepository locationRepository = LocationRepository();
  final LaboratoriesRepository laboratoriesRepository =
      LaboratoriesRepository();

  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _event;
  Map<String, dynamic>? _building;
  List<Map<String, dynamic>> _laboratories = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;
  final Map<int, Map<String, dynamic>> _buildingCache = {};

  CardDetailViewModel();

  // Getters
  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get event => _event;
  Map<String, dynamic>? get building => _building;
  List<Map<String, dynamic>> get laboratories => _laboratories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  // Métodos para manejar eventos
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await eventRepository.fetchEvents();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEventDetails(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _event = (await eventRepository.fetchEventById(eventId)).firstOrNull;

      await AnalyticsService.logUserAction(
        actionType: 'consult_event',
        eventId: eventId,
        eventType: _event?['type'],
        title: _event?['title'],
        locationId: _event?['location_id'],
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBuildingDetails(int buildingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_buildingCache.containsKey(buildingId)) {
        _building = _buildingCache[buildingId];
      } else {
        _building = await locationRepository.fetchLocationById(buildingId);
        if (_building == null) {
          throw Exception('No se encontró el edificio.');
        }
        _buildingCache[buildingId] = _building!;
      }

      _laboratories =
          await laboratoriesRepository.fetchLaboratoriesByLocation(buildingId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLaboratoryDetails(int laboratoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lab =
          await laboratoriesRepository.fetchLaboratoryById(laboratoryId);
      if (lab != null) {
        _laboratories = [
          lab
        ]; 
      } else {
        throw Exception('Laboratorio no encontrado.');
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualizar el índice seleccionado
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Navegar a la página de mapa
  void goToMapPage(BuildContext context) {
    updateSelectedIndex(2); // Índice 2 es para la página del mapa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(initialIndex: 2),
      ),
    );
  }

  // Navegar a la página principal con el índice seleccionado
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
}

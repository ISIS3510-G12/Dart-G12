import 'package:flutter/material.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../views/main_screen.dart';
import '../../data/services/analytics_service.dart';
import '../../data/repositories/favorite_repository.dart';

class CombinedViewModel extends ChangeNotifier {
  final EventRepository eventRepository = EventRepository();
  final LocationRepository locationRepository = LocationRepository();
  final FavoriteRepository favoriteRepository = FavoriteRepository();

  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _event;  // Detalles del evento
  Map<String, dynamic>? _building;  // Detalles del edificio
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;
  final Map<int, Map<String, dynamic>> _buildingCache = {};
  bool isFavorite = false;
  
  CombinedViewModel();

  // Getters
  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get event => _event;
  Map<String, dynamic>? get building => _building;
  List<Map<String, dynamic>> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  Future<void> checkIfFavorite() async {
    if (_event == null) return;
    final favorites = await favoriteRepository.getFavoriteEvents();
    isFavorite = favorites.any((fav) => fav['id'] == _event!['id']);
    notifyListeners();
  }

  Future<void> addToFavorites() async {
    if (_event != null) {
      await favoriteRepository.saveFavoriteEvent(_event!);
      isFavorite = true;
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites() async {
    if (_event != null) {
      await favoriteRepository.removeFavoriteEvent(_event!);
      isFavorite = false;
      notifyListeners();
    }
  }


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

      await checkIfFavorite(); // Verificar favorito al cargar el evento
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Métodos para manejar edificios y lugares
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

      _places = await locationRepository.fetchPlacesByLocation(buildingId);
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

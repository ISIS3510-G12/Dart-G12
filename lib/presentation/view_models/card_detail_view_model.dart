import 'dart:developer';

import 'package:flutter/material.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../views/main_screen.dart';
import '../../data/services/analytics_service.dart';
import '../../data/repositories/laboratories_repository.dart';
import '../../data/repositories/access_repository.dart';
import '../../data/repositories/favorite_repository.dart'; 

class CardDetailViewModel extends ChangeNotifier {
  final EventRepository eventRepository = EventRepository();
  final LocationRepository locationRepository = LocationRepository();
  final LaboratoriesRepository laboratoriesRepository = LaboratoriesRepository();
  final AccessRepository accessRepository = AccessRepository();
  final FavoriteRepository favoriteRepository = FavoriteRepository();

  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _event;
  Map<String, dynamic>? _building;
  List<Map<String, dynamic>> _laboratories = [];
  List<Map<String, dynamic>> _access = [];
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
  List<Map<String, dynamic>> get access => _access;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  // Toggle favorite for an individual item
  Future<bool> toggleFavorite(String id, Map<String, dynamic> item) async {
    final wasFav = await favoriteRepository.isFavorite(id);

    if (wasFav) {
      await favoriteRepository.removeFavorite(id);
      log('Favorito eliminado: $id');
    } else {
      await favoriteRepository.saveFavorite(item);
      log('Favorito agregado: $item');
    }
    final current = await favoriteRepository.isFavorite(id);
    log( 'Estado actual del favorito: $current');
    notifyListeners();
    await AnalyticsService.logFeatureInteraction(feature: "change_favorites");
    return current;
  }

  
  Future<bool> isFavorite(String id) async {
    return await favoriteRepository.isFavorite(id);
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
    // Traemos los detalles del evento
    final eventList = await eventRepository.fetchEventById(eventId);
    if (eventList.isNotEmpty) {
      _event = eventList.first;
    } else {
      throw Exception('Evento no encontrado.');
    }

    // Registramos la acción del usuario en el servicio de Analytics
    await AnalyticsService.logUserAction(
      actionType: 'consult_event',
      eventId: eventId,
      eventType: _event?['type'],
      title: _event?['title'],
      locationId: _event?['location_id'],
    );
    await AnalyticsService.logFeatureInteraction(feature: "view_details");
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
      await AnalyticsService.logFeatureInteraction(feature: "view_details");
      _laboratories =
          await laboratoriesRepository.fetchLaboratoriesByLocation(buildingId);
      _access = await accessRepository.fetchAccessByLocation(buildingId);
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
        _laboratories = [lab];
      } else {
        throw Exception('Laboratorio no encontrado.');
      }
      await AnalyticsService.logFeatureInteraction(feature: "view_details");
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAccessDetails(int accessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final accList = await accessRepository
          .fetchAccessById(accessId); 
      _access = accList;
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
    updateSelectedIndex(2);
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

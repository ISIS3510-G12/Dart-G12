import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/services/analytics_service.dart';
import 'dart:developer';

class MapViewModel extends ChangeNotifier {
  final MapRepository repository = MapRepository();

  // Datos obtenidos del repositorio
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> recommendations = [];
  List<Map<String, dynamic>> mostSearched = [];

  // Ubicación actual del usuario para centrar el mapa
  LatLng? currentLocation;

  GoogleMapController? mapController;

  MapViewModel() {
    _init();
  }

  Future<void> _init() async {
    await getCurrentLocation();
    await fetchAllData();
  }

  /// Verifica y solicita permisos de ubicación
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  /// Obtiene la ubicación actual y centra el mapa
  Future<void> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      log('Error obteniendo la ubicación: $e');
    }
  }

  /// Obtiene todos los datos: locations, recommendations y mostSearched
  Future<void> fetchAllData() async {
    try {
      final data = await repository.fetchAllData();
      locations        = data['locations']       ?? [];
      recommendations  = data['recommendations'] ?? [];
      mostSearched     = data['mostSearched']    ?? [];
      notifyListeners();
    } catch (e) {
      log('Error obteniendo datos: $e');
    }
  }

  /// Registra interacción cuando el usuario selecciona un ítem
  void selectItem(String type, Map<String, dynamic> item) {
    final int? locationId = item['location_id'] ?? item['event_id'];
    final String? name    = item['name']        ??
                             item['title']      ??
                             item['title_or_name'];
    if (locationId != null && name != null) {
      AnalyticsService.logLocationSearch(
        locationId: locationId,
        locationName: name,
      );
    }
  }

  /// Asocia el controlador de Google Map y centra la cámara
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 14),
      );
    }
  }
}

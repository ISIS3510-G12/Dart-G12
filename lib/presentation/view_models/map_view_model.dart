import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/services/analytics_service.dart';
import 'dart:developer';

class MapViewModel extends ChangeNotifier {
  final MapRepository repository = MapRepository();
  GoogleMapController? mapController;

  LatLng? fromLocation;
  LatLng? toLocation;
  String? fromLocationName;
  String? toLocationName;
  
  double? distance;
  Set<Polyline> polylines = {};
  Set<Circle> circles = {};
  bool showSteps = false;
  List<Map<String, dynamic>> stepNodes = [];

  final Map<String, LatLng> locations = {};
  final Map<String, int> locationIds = {};

  MapViewModel() {
    fetchLocations();
    getCurrentLocation();
  }

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

  Future<void> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      fromLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();

    } catch (e) {
      print("Error obteniendo la ubicación: \$e");
    }
  }

  Future<void> fetchLocations() async {
    try {
      final response = await repository.fetchLocations();
      locations.clear();
      locationIds.clear();

      for (var location in response) {
        final name = location['block'] as String;
        final id = location['location_id'] as int;
        final lat = location['latitude'] as double;
        final lng = location['longitude'] as double;
        locations[name] = LatLng(lat, lng);
        locationIds[name] = id;
      }
      notifyListeners();
    } catch (e) {
      print("Error obteniendo ubicaciones: \$e");
    }
  }

Future<void> fetchRoute() async {
  if (fromLocationName == null || toLocationName == null) return;

  final fromId = locationIds[fromLocationName!];
  final toId = locationIds[toLocationName!];
  if (fromId == null || toId == null) return;

  try {
    // Llamada a la función que devuelve un mapa con total_cost y path
    final shortestPath = await repository.fetchShortestPath(fromId, toId);
    log('Respuesta fetchShortestPath: $shortestPath');
    if (shortestPath == null) return;

    // Como fetchShortestPath devuelve un Map, no una lista, accedemos directo
    final pathIds = (shortestPath['path'] as List<dynamic>)
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();
    final totalCost = shortestPath['total_cost']*10000; // Convertir a metros

    log('Path IDs: $pathIds, totalCost: $totalCost');

    // Excluir el primer y último nodo de la lista
    final intermediateNodeIds = pathIds.sublist(1, pathIds.length - 1);

    // Obtener los datos de los nodos intermedios
    final fullNodes = await repository.fetchNodesByIds(intermediateNodeIds);

    stepNodes = fullNodes;

    final routePoints = fullNodes
        .map((n) => LatLng(n['lat'], n['lng']))
        .toList();

    polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.red,
        width: 4,
        points: routePoints,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      ),
    };

    circles = routePoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      Color fillColor;
      if (index == 0) {
        fillColor = Colors.pink;
      } else if (index == routePoints.length - 1) {
        fillColor = Colors.green;
      } else {
        fillColor = Colors.black;
      }
      return Circle(
        circleId: CircleId('node_$index'),
        center: point,
        radius: 4,
        fillColor: fillColor,
        strokeColor: Colors.white,
        strokeWidth: 1,
      );
    }).toSet();

    distance = totalCost is num ? totalCost.toDouble() : null;
    notifyListeners();
  } catch (e) {
    log("Error obteniendo la ruta más corta: $e");
  }
}


  void updateLocation(bool isFrom, String locationName) {
    if (isFrom) {
      fromLocation = locations[locationName];
      fromLocationName = locationName;
    } else {
      toLocation = locations[locationName];
      toLocationName = locationName;
      final locId = locationIds[locationName];
      if (locId != null) AnalyticsService.logLocationSearch(locationId: locId, locationName: locationName);
    }
    calculateDistance();
    fetchRoute();
    notifyListeners();
  }

  void calculateDistance() {
    if (fromLocation != null && toLocation != null) {
      distance = Geolocator.distanceBetween(
        fromLocation!.latitude,
        fromLocation!.longitude,
        toLocation!.latitude,
        toLocation!.longitude,
      );
    }
    notifyListeners();
  }

  void swapLocations() {
    final tmpLoc = fromLocation;
    fromLocation = toLocation;
    toLocation = tmpLoc;
    final tmpName = fromLocationName;
    fromLocationName = toLocationName;
    toLocationName = tmpName;
    calculateDistance();
    fetchRoute();
    notifyListeners();
  }

  void toggleSteps() {
    showSteps = !showSteps;
    notifyListeners();
  }
}

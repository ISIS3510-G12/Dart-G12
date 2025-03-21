import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/map_repository.dart';

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

      // Actualiza solo la ubicación actual para centrar el mapa
      fromLocation = LatLng(position.latitude, position.longitude);
      
      // NOTA: No se asigna un nombre ni se agrega al mapa "locations"
      notifyListeners();

    } catch (e) {
      print("Error obteniendo la ubicación: $e");
    }
  }

  /// Carga las ubicaciones desde el repositorio (de Supabase).
  Future<void> fetchLocations() async {
    try {
      final response = await repository.fetchLocations();
      locations.clear();
      locationIds.clear();

      for (var location in response) {
        final name = location['name'] as String;
        final id = location['id'] as int;
        final lat = location['latitude'] as double;
        final lng = location['longitude'] as double;
        locations[name] = LatLng(lat, lng);
        locationIds[name] = id;
      }
      notifyListeners();
    } catch (e) {
      print("Error obteniendo ubicaciones: $e");
    }
  }

  // El resto del código se mantiene igual...
  /// Carga la ruta seleccionada y actualiza polylines y circles.
  Future<void> fetchRoute() async {
    if (fromLocationName == null || toLocationName == null) return;

    final fromId = locationIds[fromLocationName!];
    final toId = locationIds[toLocationName!];
    if (fromId == null || toId == null) return;

    try {
      final routeResponse = await repository.fetchRouteData(fromId, toId);
      if (routeResponse == null) return;

      final routeId = routeResponse['id'];

      final startLocResponse =
          await repository.fetchLocationById(routeResponse['start_location_id']);
      final endLocResponse =
          await repository.fetchLocationById(routeResponse['end_location_id']);
      final intermediateNodes = await repository.fetchRouteNodes(routeId);

      if (startLocResponse == null || endLocResponse == null) return;

      final startNode = {
        'latitude': startLocResponse['latitude'],
        'longitude': startLocResponse['longitude'],
        'node_name': startLocResponse['name'] ?? 'Inicio',
        'node_index': 0,
      };

      final endNode = {
        'latitude': endLocResponse['latitude'],
        'longitude': endLocResponse['longitude'],
        'node_name': endLocResponse['name'] ?? 'Final',
        'node_index': -1,
      };

      final fullNodes = <Map<String, dynamic>>[];
      fullNodes.add(startNode);
      fullNodes.addAll(intermediateNodes);
      fullNodes.add(endNode);
      fullNodes.last['node_index'] = fullNodes.length - 1;

      stepNodes = fullNodes;
      final routePoints = fullNodes
          .map((n) => LatLng(n['latitude'], n['longitude']))
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
          radius: 5.5,
          fillColor: fillColor,
          strokeColor: Colors.white,
          strokeWidth: 1,
        );
      }).toSet();

      notifyListeners();
    } catch (e) {
      print("Error obteniendo la ruta: $e");
    }
  }

  /// Actualiza las ubicaciones de inicio o destino.
  void updateLocation(bool isFrom, String locationName) {
    if (isFrom) {
      fromLocation = locations[locationName];
      fromLocationName = locationName;
    } else {
      toLocation = locations[locationName];
      toLocationName = locationName;
    }
    calculateDistance();
    fetchRoute();
    notifyListeners();
  }

  /// Calcula la distancia entre dos ubicaciones.
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

  /// Intercambia las ubicaciones de inicio y destino.
  void swapLocations() {
    final tempLocation = fromLocation;
    fromLocation = toLocation;
    toLocation = tempLocation;

    final tempName = fromLocationName;
    fromLocationName = toLocationName;
    toLocationName = tempName;

    calculateDistance();
    fetchRoute();
    notifyListeners();
  }

  /// Muestra/oculta la tarjeta de pasos.
  void toggleSteps() {
    showSteps = !showSteps;
    notifyListeners();
  }
}

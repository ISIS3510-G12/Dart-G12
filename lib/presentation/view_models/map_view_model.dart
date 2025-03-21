import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/services/analytics_service.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository repository = MapRepository();

  // Estado del mapa y rutas
  late GoogleMapController mapController;

  LatLng? fromLocation;
  LatLng? toLocation;
  String? fromLocationName;
  String? toLocationName;
  double? distance;
  Set<Polyline> polylines = {};
  Set<Circle> circles = {};
  bool showSteps = false;

  // Lista de nodos para el StepsCard
  List<Map<String, dynamic>> stepNodes = [];

  /// Ubicaciones para los Dropdowns:
  final Map<String, LatLng> locations = {};

  /// Clave: nombre, Valor: id en la tabla locations
  final Map<String, int> locationIds = {};

  MapViewModel() {
    fetchLocations();
  }

  /// Carga las ubicaciones utilizando el Repository
  Future<void> fetchLocations() async {
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
  }

  /// Carga la ruta seleccionada y actualiza polylines y circles usando el Repository
  Future<void> fetchRoute() async {
    if (fromLocationName == null || toLocationName == null) return;

    final fromId = locationIds[fromLocationName!];
    final toId = locationIds[toLocationName!];
    if (fromId == null || toId == null) return;

    // Obtiene la ruta
    final routeResponse = await repository.fetchRouteData(fromId, toId);
    if (routeResponse == null) return;

    final routeId = routeResponse['id'];

    // Obtiene el nodo de inicio
    final startLocResponse =
        await repository.fetchLocationById(routeResponse['start_location_id']);
    if (startLocResponse == null) return;
    final startNode = {
      'latitude': startLocResponse['latitude'],
      'longitude': startLocResponse['longitude'],
      'node_name': startLocResponse['name'] ?? 'Inicio',
      'node_index': 0,
    };

    // Obtiene el nodo final
    final endLocResponse =
        await repository.fetchLocationById(routeResponse['end_location_id']);
    if (endLocResponse == null) return;
    final endNode = {
      'latitude': endLocResponse['latitude'],
      'longitude': endLocResponse['longitude'],
      'node_name': endLocResponse['name'] ?? 'Final',
      'node_index': -1, // Se ajusta luego
    };

    // Obtiene nodos intermedios
    final intermediateNodes = await repository.fetchRouteNodes(routeId);

    // Combina inicio, intermedios y final
    final fullNodes = <Map<String, dynamic>>[];
    fullNodes.add(startNode);
    fullNodes.addAll(intermediateNodes);
    fullNodes.add(endNode);
    fullNodes.last['node_index'] = fullNodes.length - 1;

    // Actualiza nodos, polylines y circles
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
        fillColor = Colors.pink; // Inicio
      } else if (index == routePoints.length - 1) {
        fillColor = Colors.green; // Final
      } else {
        fillColor = Colors.black; // Intermedios
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
  }

  /// Actualiza la ubicación (inicio o destino) y dispara cálculos asociados
  void updateLocation(bool isFrom, String locationName) {
    if (isFrom) {
      fromLocation = locations[locationName];
      fromLocationName = locationName;
    } else {
      toLocation = locations[locationName];
      toLocationName = locationName;

      // Registrar búsqueda de ubicación de destino
      final int? locId = locationIds[locationName];
      if (locId != null) {
        AnalyticsService.logLocationSearch(
          locationId: locId,
          locationName: locationName,
        );
      }
    }
    calculateDistance();
    fetchRoute();
    notifyListeners();
  }

  /// Calcula la distancia entre las dos ubicaciones
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

  /// Intercambia las ubicaciones de inicio y destino
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

  /// Muestra/oculta la tarjeta de pasos
  void toggleSteps() {
    showSteps = !showSteps;
    notifyListeners();
  }
}

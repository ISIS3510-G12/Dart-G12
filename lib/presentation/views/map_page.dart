import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/dropdown_container.dart';
import '../widgets/location_dropdown.dart';
import '../widgets/costum_app_bar.dart';
import '../widgets/map_view.dart';
import '../widgets/distance_card.dart';
import '../widgets/steps_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  LatLng? _fromLocation;
  LatLng? _toLocation;
  String? _fromLocationName;
  String? _toLocationName;

  double? _distance;
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  bool _showSteps = false;

  // Aquí guardamos todos los nodos (inicio, intermedios, final) para StepsCard
  List<Map<String, dynamic>> _stepNodes = [];

  final supabase = Supabase.instance.client;

  /// Clave: nombre, Valor: LatLng (para los Dropdowns)
  final Map<String, LatLng> _locations = {};

  /// Clave: nombre, Valor: id en la tabla locations
  final Map<String, int> _locationIds = {};

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  /// 1) Carga las ubicaciones de la tabla `locations`
  Future<void> _fetchLocations() async {
    final response = await supabase.from('locations').select();
    if (response.isNotEmpty) {
      setState(() {
        _locations.clear();
        _locationIds.clear();
        for (var location in response) {
          final name = location['name'] as String;
          final id = location['id'] as int;
          final lat = location['latitude'] as double;
          final lng = location['longitude'] as double;

          _locations[name] = LatLng(lat, lng);
          _locationIds[name] = id;
        }
      });
    }
  }

  /// 2) Carga la ruta seleccionada desde la tabla `routes`,
  ///    obtiene la lat/lng del inicio y fin desde `locations`,
  ///    luego carga los nodos intermedios de `route_nodes` y
  ///    combina todo en _stepNodes.
  Future<void> _fetchRoute() async {
    if (_fromLocationName == null || _toLocationName == null) return;

    final fromId = _locationIds[_fromLocationName!];
    final toId = _locationIds[_toLocationName!];
    if (fromId == null || toId == null) return;

    // 2.1) Busca la ruta en la tabla 'routes' 
    //      (aquí SÓLO existen 'id', 'start_location_id', 'end_location_id', etc.)
    final routeResponse = await supabase
        .from('routes')
        .select('id, start_location_id, end_location_id')
        .eq('start_location_id', fromId)
        .eq('end_location_id', toId)
        .maybeSingle();

    // maybeSingle() => null si no encuentra nada
    if (routeResponse == null) return;

    final routeId = routeResponse['id'];

    // 2.2) Obtiene la info de la tabla 'locations' para el start_location
    final startLocResponse = await supabase
        .from('locations')
        .select('name, latitude, longitude')
        .eq('id', routeResponse['start_location_id'])
        .maybeSingle();
    if (startLocResponse == null) return;

    final startNode = {
      'latitude': startLocResponse['latitude'],
      'longitude': startLocResponse['longitude'],
      'node_name': startLocResponse['name'] ?? 'Inicio',
      'node_index': 0,
    };

    // 2.3) Obtiene la info de la tabla 'locations' para el end_location
    final endLocResponse = await supabase
        .from('locations')
        .select('name, latitude, longitude')
        .eq('id', routeResponse['end_location_id'])
        .maybeSingle();
    if (endLocResponse == null) return;

    final endNode = {
      'latitude': endLocResponse['latitude'],
      'longitude': endLocResponse['longitude'],
      'node_name': endLocResponse['name'] ?? 'Final',
      'node_index': -1, // Lo ajustamos luego
    };

    // 2.4) Obtiene los nodos intermedios de la tabla 'route_nodes'
    final nodesResponse = await supabase
        .from('route_nodes')
        .select('latitude, longitude, node_name, node_index')
        .eq('route_id', routeId)
        .order('node_index', ascending: true);

    List<Map<String, dynamic>> intermediateNodes =
        List<Map<String, dynamic>>.from(nodesResponse);

    // 2.5) Combina inicio + intermedios + final
    final fullNodes = <Map<String, dynamic>>[];
    fullNodes.add(startNode);
    fullNodes.addAll(intermediateNodes);
    fullNodes.add(endNode);

    // Ajusta el node_index del final
    fullNodes.last['node_index'] = fullNodes.length - 1;

    // 2.6) Actualiza polylines y circles
    setState(() {
      _stepNodes = fullNodes;

      // Construye la lista de LatLng para trazar la ruta
      final routePoints = fullNodes
          .map((n) => LatLng(n['latitude'], n['longitude']))
          .toList();

      // Polylines
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.red,
          width: 4,
          points: routePoints,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      };

      // Circles (rosado inicio, negro intermedios, verde final)
      _circles = routePoints.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        Color fillColor;
        if (index == 0) {
          fillColor = Colors.pink;   // Inicio
        } else if (index == routePoints.length - 1) {
          fillColor = Colors.green;  // Final
        } else {
          fillColor = Colors.black;  // Intermedios
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
    });
  }

  /// Se llama cuando el usuario selecciona un lugar en el dropdown
  void _updateLocation(bool isFrom, String locationName) {
    setState(() {
      if (isFrom) {
        _fromLocation = _locations[locationName];
        _fromLocationName = locationName;
      } else {
        _toLocation = _locations[locationName];
        _toLocationName = locationName;
      }
      _calculateDistance();
      _fetchRoute();
    });
  }

  /// Calcula la distancia en metros entre _fromLocation y _toLocation
  void _calculateDistance() {
    if (_fromLocation != null && _toLocation != null) {
      final distance = Geolocator.distanceBetween(
        _fromLocation!.latitude,
        _fromLocation!.longitude,
        _toLocation!.latitude,
        _toLocation!.longitude,
      );
      setState(() {
        _distance = distance;
      });
    }
  }

  /// Muestra/oculta el StepsCard
  void _toggleSteps() {
    setState(() {
      _showSteps = !_showSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        dropdownFrom: DropdownContainer(
          child: LocationDropdown(
            value: _fromLocationName,
            hint: "Your Location",
            locations: _locations,
            onChanged: (newValue) {
              if (newValue != null) _updateLocation(true, newValue);
            },
          ),
        ),
        dropdownTo: DropdownContainer(
          child: LocationDropdown(
            value: _toLocationName,
            hint: "Destination",
            locations: _locations,
            onChanged: (newValue) {
              if (newValue != null) _updateLocation(false, newValue);
            },
          ),
        ),
        onSwap: () {
          setState(() {
            final temp = _fromLocation;
            _fromLocation = _toLocation;
            _toLocation = temp;

            final tempName = _fromLocationName;
            _fromLocationName = _toLocationName;
            _toLocationName = tempName;

            _calculateDistance();
            _fetchRoute();
          });
        },
        onMoreOptions: () {},
      ),
      body: Stack(
        children: [
          // Mapa
          MapView(
            initialCameraPosition: CameraPosition(
              target: _locations.isNotEmpty
                  ? _locations.values.first
                  : const LatLng(4.602196, -74.065816),
              zoom: 17,
            ),
            polylines: _polylines,
            circles: _circles,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Tarjeta inferior (distancia o lista de pasos)
          if (_fromLocation != null && _toLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _showSteps
                  ? StepsCard(
                      onClose: _toggleSteps,
                      // Pasa la lista de nodos (inicio, intermedios, final)
                      nodes: _stepNodes,
                    )
                  : DistanceCard(
                      distance: _distance ?? 0,
                      onStepsPressed: _toggleSteps,
                    ),
            ),
        ],
      ),
    );
  }
}

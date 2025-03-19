import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/costum_app_bar.dart';
import '../widgets/dropdown_container.dart';
import '../widgets/distance_card.dart';
import '../widgets/steps_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  LatLng? _fromLocation;
  LatLng? _toLocation;
  double? _distance;
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  bool _showSteps = false;

  final Map<String, LatLng> _locations = {
    "Edificio ML": const LatLng(4.602196, -74.065816),
    "Edificio W": const LatLng(4.600500, -74.064800),
    "Edificio SD": const LatLng(4.601393, -74.065417),
    "Edificio RGD": const LatLng(4.601800, -74.066200),
  };

  final List<LatLng> _mlToWNodes = [
    const LatLng(4.602196, -74.065816), // Inicio: Edificio ML
    const LatLng(4.601800, -74.065600),
    const LatLng(4.601400, -74.065200),
    const LatLng(4.600900, -74.064900),
    const LatLng(4.600500, -74.064800), // Final: Edificio W
  ];

  void _updateLocation(bool isFrom, String locationName) {
    setState(() {
      if (isFrom) {
        _fromLocation = _locations[locationName];
      } else {
        _toLocation = _locations[locationName];
      }
      _calculateDistance();
      _updateRoute();
    });
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
      _calculateDistance();
      _updateRoute();
    });
  }

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

  void _updateRoute() {
    if (_fromLocation != null && _toLocation != null) {
      setState(() {
        _polylines.clear();
        _circles.clear();

        if (_fromLocation == _locations["Edificio ML"] && _toLocation == _locations["Edificio W"]) {
          // Línea punteada de la ruta
          _polylines = {
            Polyline(
              polylineId: const PolylineId("ml_to_w"),
              color: Colors.red,
              width: 4,
              points: _mlToWNodes,
              patterns: [PatternItem.dash(10), PatternItem.gap(5)],
            ),
          };

          // Dibujar los círculos en cada nodo con mayor tamaño
          _circles = _mlToWNodes.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            Color fillColor;
            if (index == 0) {
              fillColor = Colors.green; // Inicio
            } else if (index == _mlToWNodes.length - 1) {
              fillColor = Colors.red; // Final
            } else {
              fillColor = Colors.black; // Intermedios
            }
            return Circle(
              circleId: CircleId('node_$index'),
              center: point,
              radius: 5.5, // Círculo un poco más grande
              fillColor: fillColor,
              strokeColor: Colors.white,
              strokeWidth: 1,
            );
          }).toSet();
        }
      });
    }
  }

  void _toggleSteps() {
    setState(() {
      _showSteps = !_showSteps;
    });
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return DropdownContainer(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        dropdownFrom: _buildDropdownContainer(
          child: DropdownButton<String>(
            value: _fromLocation != null
                ? _locations.keys.firstWhere(
                    (k) => _locations[k] == _fromLocation,
                    orElse: () => "Edificio ML",
                  )
                : null,
            hint: const Text("Your Location"),
            isExpanded: true,
            onChanged: (String? newValue) {
              if (newValue != null) _updateLocation(true, newValue);
            },
            items: _locations.keys
                .map((String key) => DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    ))
                .toList(),
          ),
        ),
        dropdownTo: _buildDropdownContainer(
          child: DropdownButton<String>(
            value: _toLocation != null
                ? _locations.keys.firstWhere(
                    (k) => _locations[k] == _toLocation,
                    orElse: () => "Edificio W",
                  )
                : null,
            hint: const Text("Destination"),
            isExpanded: true,
            onChanged: (String? newValue) {
              if (newValue != null) _updateLocation(false, newValue);
            },
            items: _locations.keys
                .map((String key) => DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    ))
                .toList(),
          ),
        ),
        onSwap: _swapLocations,
        onMoreOptions: () {},
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(
              target: _locations["Edificio ML"]!,
              zoom: 17,
            ),
            zoomControlsEnabled: false,
            markers: {},
            polylines: _polylines,
            circles: _circles,
            onMapCreated: (controller) => _mapController = controller,
          ),
          if (_fromLocation != null && _toLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _showSteps
                  ? StepsCard(onClose: _toggleSteps)
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

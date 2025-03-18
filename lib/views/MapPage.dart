import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  final Map<String, LatLng> _locations = {
    "Edificio SD": LatLng(4.601393, -74.065417),
    "Edificio ML": LatLng(4.602196, -74.065816),
    "Edificio W": LatLng(4.600500, -74.064800),
    "Edificio RGD": LatLng(4.601800, -74.066200),
  };

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
      LatLng? temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
      _calculateDistance();
      _updateRoute();
    });
  }

  void _calculateDistance() {
    if (_fromLocation != null && _toLocation != null) {
      double distance = Geolocator.distanceBetween(
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
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: [_fromLocation!, _toLocation!],
          ),
        };
      });
    }
  }

  /// Línea punteada vertical. Ajusta la altura con [height] para mayor separación.
  Widget _buildDottedLine(double height) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          const dashHeight = 3.0;
          const dashSpace = 2.0;
          final dashCount = (totalHeight / (dashHeight + dashSpace)).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dashCount, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: dashSpace),
                child: Container(
                  width: 1,
                  height: dashHeight,
                  color: Colors.grey,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildDropdownContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      height: 48, // Ajusta para hacerlo más grande/pequeño
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 130,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fiber_manual_record, color: Colors.blue, size: 20),
                _buildDottedLine(30),
                const Icon(Icons.location_on, color: Colors.red, size: 20),
              ],
            ),
            const SizedBox(width: 12),
           
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fila 1: Your Location + menú ...
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownContainer(
                          child: DropdownButton<String>(
                            value: _fromLocation != null
                                ? _locations.keys.firstWhere(
                                    (k) => _locations[k] == _fromLocation,
                                    orElse: () => "Edificio SD",
                                  )
                                : null,
                            hint: const Text("Your Location"),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) _updateLocation(true, newValue);
                            },
                            items: _locations.keys.map((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Fila 2: Destination + swap
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownContainer(
                          child: DropdownButton<String>(
                            value: _toLocation != null
                                ? _locations.keys.firstWhere(
                                    (k) => _locations[k] == _toLocation,
                                    orElse: () => "Edificio ML",
                                  )
                                : null,
                            hint: const Text("Destination"),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) _updateLocation(false, newValue);
                            },
                            items: _locations.keys.map((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_vert, color: Colors.black),
                        onPressed: _swapLocations,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(
              target: _locations["Edificio SD"]!,
              zoom: 17,
            ),
            zoomControlsEnabled: false, 
            markers: {
              if (_fromLocation != null)
                Marker(
                  markerId: const MarkerId("from"),
                  position: _fromLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              if (_toLocation != null)
                Marker(
                  markerId: const MarkerId("to"),
                  position: _toLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
            },
            polylines: _polylines,
            onMapCreated: (controller) => _mapController = controller,
          ),
          // Tarjeta inferior con la distancia
        if (_fromLocation != null && _toLocation != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Bordes redondeados arriba
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra deslizante
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Espacio entre la barra y el contenido
                  
                  // Tiempo y distancia
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      children: [
                        TextSpan(
                          text: "${(_distance! / 1000 * 7).toStringAsFixed(0)} min ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "(${_distance?.toStringAsFixed(0)} m)",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Dirección
                  const Text(
                    "Cl. 19A #1e-37, Bogotá",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Botón Steps
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.list, color: Colors.white),
                    label: const Text("Steps", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),


        ],
      ),
    );
  }
}

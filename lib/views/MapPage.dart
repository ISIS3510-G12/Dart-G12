import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  late GoogleMapController _mapController;

  void _goToLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locations.first.latitude, locations.first.longitude),
            zoom: 12,
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo encontrar la ubicación")),
      );
    }
  }

  void _swapLocations() {
    setState(() {
      String temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40), // Bajamos más la barra
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          hintText: 'Mi ubicación...',
                        ),
                        onSubmitted: (value) => _goToLocation(value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12), // Espacio entre los campos
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          hintText: 'Destino...',
                        ),
                        onSubmitted: (value) => _goToLocation(value),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_vert),
                      onPressed: _swapLocations,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15), // Espacio extra antes del mapa
          Expanded(
            child: GoogleMap(
              mapType: MapType.satellite, // Establecer mapa en vista satelital
              initialCameraPosition: CameraPosition(
                target: LatLng(4.6010, -74.0656), // Universidad de los Andes, Bogotá
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
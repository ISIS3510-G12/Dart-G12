import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  LatLng _fromLocation = LatLng(4.601393, -74.065417); // Edificio SD
  LatLng _toLocation = LatLng(4.602196, -74.065816); // Edificio ML

  final Map<String, LatLng> _locations = {
    "Edificio SD": LatLng(4.601393, -74.065417),
    "Edificio ML": LatLng(4.602196, -74.065816),
    "Edificio W": LatLng(4.600500, -74.064800),
    "Edificio RGD": LatLng(4.601800, -74.066200),
  };

  void _updateLocation(bool isFrom, String locationName) {
    setState(() {
      if (isFrom) {
        _fromLocation = _locations[locationName]!;
      } else {
        _toLocation = _locations[locationName]!;
      }
    });
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_fromLocation, 18));
  }

  void _swapLocations() {
    setState(() {
      LatLng temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_fromLocation, 18));
    Future.delayed(Duration(milliseconds: 300), () {
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(_fromLocation, 18));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(
              target: _fromLocation,
              zoom: 17,
            ),
            markers: {
              Marker(
                markerId: MarkerId("from"),
                position: _fromLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
              Marker(
                markerId: MarkerId("to"),
                position: _toLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.blue, size: 28),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _locations.keys.firstWhere((k) => _locations[k] == _fromLocation, orElse: () => "Edificio SD"),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) _updateLocation(true, newValue);
                            },
                            items: _locations.keys.map<DropdownMenuItem<String>>((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 28),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _locations.keys.firstWhere((k) => _locations[k] == _toLocation, orElse: () => "Edificio ML"),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) _updateLocation(false, newValue);
                            },
                            items: _locations.keys.map<DropdownMenuItem<String>>((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.swap_horiz, color: Colors.grey, size: 28),
                          onPressed: _swapLocations,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final CameraPosition initialCameraPosition;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final Function(GoogleMapController) onMapCreated;

  const MapView({
    super.key,
    required this.initialCameraPosition,
    required this.polylines,
    required this.circles,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.satellite,
      initialCameraPosition: initialCameraPosition,
      zoomControlsEnabled: false,
      markers: {},
      polylines: polylines,
      circles: circles,
      onMapCreated: onMapCreated,
      myLocationEnabled: true,
      minMaxZoomPreference: const MinMaxZoomPreference(17.5,20),
    );
  }
}

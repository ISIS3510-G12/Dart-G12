import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final Map<String, LatLng> locations;
  final ValueChanged<String?> onChanged;

  const LocationDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.locations,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      onChanged: onChanged,
      items: locations.keys.map((String key) {
        return DropdownMenuItem<String>(
          value: key,
          child: Text(key),
        );
      }).toList(),
    );
  }
}

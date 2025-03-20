import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';

class CardViewModel extends ChangeNotifier {
  final LocationRepository repository;
  Map<String, dynamic>? _building;
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = false;
  String? _error;

  CardViewModel({required this.repository});

  // Getters
  Map<String, dynamic>? get building => _building;
  List<Map<String, dynamic>> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🔹 Cargar datos del edificio y sus lugares
  Future<void> fetchBuildingDetails(int buildingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener el edificio
      _building = await repository.fetchLocationById(buildingId);
      if (_building == null) {
        throw Exception('No se encontró el edificio.');
      }

      // Obtener los lugares dentro del edificio
      _places = await repository.fetchPlacesByLocation(buildingId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

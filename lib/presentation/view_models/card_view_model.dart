import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';
import '../views/main_screen.dart';

class CardViewModel extends ChangeNotifier {
  final LocationRepository repository = LocationRepository();
  Map<String, dynamic>? _building;
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  CardViewModel();

  // Getters
  Map<String, dynamic>? get building => _building;
  List<Map<String, dynamic>> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

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

  /// 🔹 Actualizar el índice seleccionado
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToMapPage(BuildContext context) {
    updateSelectedIndex(2);  // Índice 2 es para la página del mapa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)),
    );
  }

    void onItemTapped(BuildContext context, int index) {
    _selectedIndex = index;
    notifyListeners();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }
}

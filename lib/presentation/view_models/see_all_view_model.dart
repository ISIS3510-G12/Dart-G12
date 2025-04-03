import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';
import '../views/main_screen.dart';

class SeeAllViewModel extends ChangeNotifier {
  final LocationRepository repository = LocationRepository();
  List<Map<String, dynamic>> _buildings = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  SeeAllViewModel();

  /// Getters
  List<Map<String, dynamic>> get buildings => _buildings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  /// Método para obtener los edificios desde Supabase
  Future<void> fetchBuildings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _buildings = await repository.fetchBuildings();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Método para actualizar el índice seleccionado y navegar a `MainScreen`
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

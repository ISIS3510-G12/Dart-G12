import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';

class SeeAllViewModel extends ChangeNotifier {
  final LocationRepository repository = LocationRepository();
  List<Map<String, dynamic>> _buildings = [];
  bool _isLoading = false;
  String? _error;

  SeeAllViewModel();

  /// Getters
  List<Map<String, dynamic>> get buildings => _buildings;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}

import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/analytics_service.dart';
import 'dart:developer';

class HomeViewModel extends ChangeNotifier {
  late final AuthService _authService;
  late final HomeRepository _homeRepository;

  String _userName = "Guest";
  String? _avatarUrl;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _mostSearchedLocations = [];
  List<Map<String, dynamic>> _laboratories = []; // 🧪 NUEVO

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get mostSearchedLocations => _mostSearchedLocations;
  List<Map<String, dynamic>> get laboratories => _laboratories; // 🧪 NUEVO

  HomeViewModel() {
    _authService = AuthService();
    _homeRepository = HomeRepository();
    _initialize();
  }

  void _initialize() {
    loadUserName();
    loadUserAvatar();
    loadAllData();
  }

  void loadUserName() {
    final fullName = _authService.getCurrentUsername();
    if (fullName != null && fullName.isNotEmpty) {
      _userName = fullName.split(' ')[0];
      notifyListeners();
    }
  }

  void loadUserAvatar() {
    final avatar = _authService.getUserAvatar();
    if (avatar != null && avatar.isNotEmpty) {
      _avatarUrl = avatar;
      notifyListeners();
    }
  }

  Future<void> loadAllData() async {
    try {
      final data = await _homeRepository.fetchAllData();
      _locations = data['locations'] ?? [];
      _mostSearchedLocations = data['mostSearched'] ?? [];
      _laboratories = data['laboratories'] ?? []; // 🧪 NUEVO
    } catch (error) {
      log('Error cargando los datos del home: $error');
    }
    notifyListeners();
  }

}


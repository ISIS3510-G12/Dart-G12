import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/home_repository.dart';
import 'dart:developer';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final HomeRepository _homeRepository = HomeRepository();

  String _userName = "Guest";
  String? _avatarUrl;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _mostSearchedLocations = [];
  List<Map<String, dynamic>> _laboratories = [];
  List<Map<String, dynamic>> _access = [];
  bool _isLoading = false;
  String? _error;

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get events => _events;
  List<Map<String, dynamic>> get mostSearchedLocations =>_mostSearchedLocations;
  List<Map<String, dynamic>> get laboratories => _laboratories;
  List<Map<String, dynamic>> get access => _access;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeViewModel() {
    _initialize();
  }

  void _initialize() {
    _loadUserData();
    _loadAllData();
  }

  Future<void> _loadUserData() async {
    _userName = _authService.getCurrentUsername()?.split(' ').first ?? "Guest";
    final prefs = await SharedPreferences.getInstance();
    _avatarUrl = prefs.getString('avatar_path') ?? ''; 
    notifyListeners();
  }

  Future<void> _loadAllData() async {
    _startLoading();
    try {
      final data = await _homeRepository.fetchAllData();
      _updateData(data);
      _clearError();
    } catch (error, stackTrace) {
      log('Error loading home data', error: error, stackTrace: stackTrace);
      _setError('Error loading data. Please try again later.');
    } finally {
      _stopLoading();
    }
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _updateData(Map<String, List<Map<String, dynamic>>> data) {
    _locations = data['locations'] ?? [];
    _events = data['events'] ?? [];
    _mostSearchedLocations = data['mostSearched'] ?? [];
    _laboratories = data['laboratories'] ?? [];
    _access = data['access'] ?? [];
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _homeRepository.fetchEverythingInBackground(null);
    await _loadAllData();
  }

  // Métodos adicionales para operaciones específicas
  Future<void> updateUserProfile() async {
    _loadUserData();
    notifyListeners();
  }
}

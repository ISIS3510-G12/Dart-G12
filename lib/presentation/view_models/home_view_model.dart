import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/analytics_service.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

class HomeViewModel extends ChangeNotifier {
  late final AuthService _authService;
  late final HomeRepository _homeRepository;

  String _userName = "Guest";
  String? _avatarUrl;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _mostSearchedLocations = [];

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  List<Map<String, dynamic>> get mostSearchedLocations => _mostSearchedLocations;

  HomeViewModel() {
    _authService = AuthService();
    _homeRepository = HomeRepository();
    _initialize();
  }

  void _initialize() {
    loadUserName();
    loadUserAvatar();
    loadLocations(); // Cargar ubicaciones desde Supabase
  }

  void loadUserName() {
    final fullName = _authService.getCurrentUsername();
    if (fullName != null && fullName.isNotEmpty) {
      _userName = fullName.split(' ')[0]; // Solo el primer nombre
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

  Future<void> loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocations = prefs.getString('locations');
    
    if (savedLocations != null) {
      _locations = List<Map<String, dynamic>>.from(json.decode(savedLocations)); // Si existe, carga desde local
    } else {
      try {
        _locations = await _homeRepository.fetchLocations();
        saveLocations();  // Guardar en caché local
      } catch (error) {
        log('Error al cargar las ubicaciones', error: error);
      }
    }
    notifyListeners();
  }

  Future<void> saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locations', json.encode(_locations));  // Guardar las ubicaciones como JSON
  }

  Future<void> loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecommendations = prefs.getString('recommendations');
    
    if (savedRecommendations != null) {
      _recommendations = List<Map<String, dynamic>>.from(json.decode(savedRecommendations)); // Cargar desde local
    } else {
      try {
        _recommendations = await _homeRepository.fetchRecommendations();
        saveRecommendations();  // Guardar en caché local
      } catch (error) {
        log('Error al cargar las recomendaciones', error: error);
      }
    }
    notifyListeners();
  }

  Future<void> saveRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('recommendations', json.encode(_recommendations));  // Guardar las recomendaciones como JSON
  }

  Future<void> loadMostSearchedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMostSearchedLocations = prefs.getString('mostSearchedLocations');
    
    if (savedMostSearchedLocations != null) {
      _mostSearchedLocations = List<Map<String, dynamic>>.from(json.decode(savedMostSearchedLocations)); // Cargar desde local
    } else {
      try {
        _mostSearchedLocations = await _homeRepository.fetchMostSearchedLocations();
        saveMostSearchedLocations();  // Guardar en caché local
      } catch (error) {
        print('Error al cargar los lugares más buscados: $error');
      }
    }
    notifyListeners();
  }

  Future<void> saveMostSearchedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('mostSearchedLocations', json.encode(_mostSearchedLocations));  // Guardar los lugares más buscados como JSON
  }

  void onRecommendationTap(Map<String, dynamic> recommendation) {
    AnalyticsService.logUserAction(
      actionType: 'consult_event',
      eventId: recommendation['id'],
      eventType: recommendation['type'] ?? 'other',
      locationId: recommendation['location_id'],
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/analytics_service.dart';

class HomeViewModel extends ChangeNotifier {
  late final AuthService _authService;
  late final HomeRepository _homeRepository;

  String _userName = "Guest";
  String? _avatarUrl;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _recommendations = [];

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get recommendations => _recommendations;

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
    try {
      _locations = await _homeRepository.fetchLocations();
      notifyListeners(); // Siempre notificamos
    } catch (error) {
      print('Error al cargar las ubicaciones: $error');
    }
  }

  Future<void> loadRecommendations() async {
    try {
      _recommendations = await _homeRepository.fetchRecommendations();
      notifyListeners();
    } catch (error) {
      print('Error al cargar las recomendaciones: $error');
    }
  }

  void onRecommendationTap(Map<String, dynamic> recommendation) {
    AnalyticsService.logUserAction(
      actionType: 'consult_event',
      eventId: recommendation['id'],
      eventType: recommendation['type'] ?? 'other',
      locationId: recommendation['location_id'],
    );
  }

  Map<String, dynamic>? _mostSearchedLocation;
  Map<String, dynamic>? get mostSearchedLocation => _mostSearchedLocation;

  Future<void> loadMostSearchedLocation() async {
    try {
      _mostSearchedLocation = await _homeRepository.fetchMostSearchedLocation();
      print('Loaded Most Searched Location: $_mostSearchedLocation'); // Debugging
      notifyListeners();
    } catch (error) {
      print('Error al cargar el lugar más buscado: $error');
    }
  }
}

import 'package:dart_g12/data/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();


  String? currentUsername;
  String? avatarUrl;

  ProfileViewModel() {
    _loadUserData();
    loadUserAvatar();
  }

  Future<void> _loadUserData() async {
    currentUsername = _authService.getCurrentUsername();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    try {
      await AnalyticsService.logFeatureInteraction(feature: "log_out");
    } catch(e){
      print("Error al registrar el log de cierre de sesion: $e");
    }
    notifyListeners();
    
  }

  Future<void> loadUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    avatarUrl = prefs.getString('avatar_path') ?? ''; 
    notifyListeners();
  }


}
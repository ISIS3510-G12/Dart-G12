import 'package:dart_g12/data/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';
import 'package:dart_g12/presentation/views/main_screen.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();


  String? currentUsername;
  String? avatarUrl;

  ProfileViewModel() {
    _loadUserData();
  }

  void _loadUserData() {
    currentUsername = _authService.getCurrentUsername();
    avatarUrl = _authService.getUserAvatar();
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

  void loadUserAvatar() {
    final avatar = _authService.getUserAvatar();
    if (avatar != null && avatar.isNotEmpty) {
      avatarUrl = avatar;
      notifyListeners();
    }
  }


}
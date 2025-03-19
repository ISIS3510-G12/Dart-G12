import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  String? currentUsername;

  ProfileViewModel() {
    _loadUserData();
  }

  void _loadUserData() {
    currentUsername = _authService.getCurrentUsername();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}

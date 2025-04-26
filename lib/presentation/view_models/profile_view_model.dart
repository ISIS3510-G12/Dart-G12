import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';
import 'package:dart_g12/presentation/views/main_screen.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  int _selectedIndex = 4;
  
  int get selectedIndex => _selectedIndex;

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
    notifyListeners();
    
  }

  void loadUserAvatar() {
    final avatar = _authService.getUserAvatar();
    if (avatar != null && avatar.isNotEmpty) {
      avatarUrl = avatar;
      notifyListeners();
    }
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
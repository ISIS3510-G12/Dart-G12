import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Controladores de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Estado de carga y visibilidad de contraseña
  bool _isLoading = false;
  bool _isObscure = true;

  bool get isLoading => _isLoading;
  bool get isObscure => _isObscure;

  void togglePasswordVisibility() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  // Método para iniciar sesión
  Future<void> login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Liberar controladores
  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}

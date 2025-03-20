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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validaciones antes de llamar a Supabase
    if (email.isEmpty && password.isEmpty) {
      _showSnackBar(context, "All fields are required.");
      return;
    }

    if (email.isEmpty) {
      _showSnackBar(context, "Email cannot be empty.");
      return;
    }

    if (password.isEmpty) {
      _showSnackBar(context, "Password cannot be empty.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (context.mounted) {
        String errorMessage = _handleAuthError(e.toString());
        _showSnackBar(context, errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manejo de errores de Supabase
  String _handleAuthError(String error) {
    if (error.contains("invalid_credentials")) {
      return "Invalid email or password. Please try again.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Mostrar mensajes en pantalla
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFEA1D5D)),
    );
  }

  // Liberar controladores
  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}

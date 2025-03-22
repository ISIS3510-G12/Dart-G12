import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isObscure1 = true;
  bool isObscure2 = true;

  void toggleObscureText(bool isConfirm) {
    if (isConfirm) {
      isObscure2 = !isObscure2;
    } else {
      isObscure1 = !isObscure1;
    }
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final displayName = displayNameController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validaciones personalizadas
    String? error =
        _validateInputs(email, password, displayName, confirmPassword);
    if (error != null) {
      _showSnackBar(context, error);
      return;
    }

    try {
      await _authService.signUpWithEmailPassword(email, password, displayName);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = _handleAuthError(e.toString());
        _showSnackBar(context, errorMessage);
      }
    }
  }

  // Validar los inputs antes de enviarlos
  String? _validateInputs(String email, String password, String displayName,
      String confirmPassword) {
    if (displayName.isEmpty) return "Full name is required.";
    if (email.isEmpty || !email.contains("@")) {
      return "Enter a valid email address.";
    }
    if (password.length < 6) return "Password must be at least 6 characters.";
    if (password != confirmPassword) return "Passwords don't match.";
    return null;
  }

  // Manejar errores y personalizarlos
  String _handleAuthError(String error) {
    if (error.contains("user_already_exists")) {
      return "This email is already registered.";
    } else if (error.contains("invalid-email")) {
      return "Invalid email format.";
    } else if (error.contains("weak-password")) {
      return "Password is too weak. Try a stronger one.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Mostrar el mensaje en pantalla
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFEA1D5D)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

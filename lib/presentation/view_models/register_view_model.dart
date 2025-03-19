import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
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

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }

    try {
      await _authService.signUpWithEmailPassword(email, password, displayName);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
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

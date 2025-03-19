import 'package:dart_g12/data/model/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //sign up botton pressed

  void signUp() async {
    //prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    //check that passwords match

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password don't match")));
      return;
    }

    // attempt sign up

    try {
      await authService.signUpWithEmailPassword(email, password);

      // pop register page
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          //Email
          TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email")),

          //Password
          TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password")),

          // Confirm Password
          TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password")),

          //Button
          ElevatedButton(onPressed: signUp, child: const Text("Sign Up")),

          const SizedBox(height: 12),

        ],
      ),
    );
  }
}

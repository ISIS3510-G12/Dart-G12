import 'package:dart_g12/data/model/auth_service.dart';
import 'package:dart_g12/views/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // get auth service
  final authService = AuthService();

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // login button pressed
  void login() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login

    try {
      await authService.signInWithEmailPassword(email, password);
    }

    //catch any errors...
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          //Button
          ElevatedButton(onPressed: login, child: const Text("Login")),

          const SizedBox(height: 12),

          GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPage())),
              child: const Center(child: Text("Don't have an account? Sign Up"))),
        ],
      ),
    );
  }
}

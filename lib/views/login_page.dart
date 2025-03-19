import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/auth_service.dart';
import 'package:dart_g12/views/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Auth Service
  final authService = AuthService();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              "assets/images/andes.jpg", // Asegúrate de tener esta imagen en assets
              fit: BoxFit.cover,
            ),
          ),

          // Capa de color oscuro semi-transparente
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Contenedor del formulario
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    const Text(
                      "Find Your Way Around",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your interactive campus map at a glance",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),

                    // Campo de Email
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: "Email or Phone Number",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo de Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Olvidó su contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {}, // Agrega la acción aquí
                        child: const Text("Forgot password?",
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),

                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Sign In",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divider
                    const Text("or sign in with",
                        style: TextStyle(color: Colors.white70)),

                    const SizedBox(height: 12),

                    // Botones de redes sociales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton("assets/google.png"), // Google
                        const SizedBox(width: 12),
                        _socialButton("assets/apple.png"), // Apple
                        const SizedBox(width: 12),
                        _socialButton("assets/facebook.png"), // Facebook
                      ],
                    ),

                    const SizedBox(height: 16),

                    // No tienes cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("I don't have an account?",
                            style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          ),
                          child: const Text("Sign Up",
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los botones de redes sociales
  Widget _socialButton(String imagePath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(imagePath, width: 30, height: 30),
      ),
    );
  }
}

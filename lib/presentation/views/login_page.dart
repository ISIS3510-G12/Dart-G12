import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_g12/presentation/view_models/login_view_model.dart';
import 'package:dart_g12/presentation/views/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/andes.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF050F2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Find Your Way Around",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA1D5D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your interactive campus map at a glance",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 24),

                          // Campo de Email
                          TextField(
                            controller: viewModel.emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Email",
                              hintStyle:
                                  const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Campo de Password
                          TextField(
                            controller: viewModel.passwordController,
                            obscureText: viewModel.isObscure,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(viewModel.isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: viewModel.togglePasswordVisibility,
                              ),
                              hintStyle:
                                  const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {}, // Agrega la acción aquí
                              child: const Text("Forgot password?",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),

                          // Botón de Login con indicador de carga
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () => viewModel.login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA1D5D),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(56),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Sign In",
                                      style: TextStyle(color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text("or sign in with",
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("I don't have an account?",
                                  style: TextStyle(color: Colors.white)),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                ),
                                child: const Text("Sign Up",
                                    style: TextStyle(color: Color(0xFFEA1D5D))),
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
        },
      ),
    );
  }
}

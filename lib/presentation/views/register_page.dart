import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_g12/presentation/view_models/register_view_model.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
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
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA1D5D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Unlock your campus experience",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextField(
                            controller: viewModel.displayNameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Full Name",
                              hintStyle: const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: viewModel.emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Email",
                              hintStyle: const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: viewModel.passwordController,
                            obscureText: viewModel.isObscure1,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(viewModel.isObscure1
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => viewModel.toggleObscureText(false),
                              ),
                              hintStyle: const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: viewModel.confirmPasswordController,
                            obscureText: viewModel.isObscure2,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Confirm Password",
                              suffixIcon: IconButton(
                                icon: Icon(viewModel.isObscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => viewModel.toggleObscureText(true),
                              ),
                              hintStyle: const TextStyle(color: Color(0xFF6C757D)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => viewModel.signUp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA1D5D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(56),
                                ),
                              ),
                              child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?", style: TextStyle(color: Colors.white)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Sign In", style: TextStyle(color: Color(0xFFEA1D5D))),
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

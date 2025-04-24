import 'package:dart_g12/presentation/view_models/auth_gate.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/andes.jpg", // Asegúrate de tener esta imagen
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Explor',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Andes',
                      style: TextStyle(color: Color(0xFFEA1D5D)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300, // Ajusta la altura para centrar mejor
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFF050F2C),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centrado vertical
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centrado horizontal
                children: [
                  const Text(
                    "Ready to explore your campus?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthGate()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA1D5D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(54),
                        ),
                      ),
                      child: const Text(
                        "Start Exploring",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

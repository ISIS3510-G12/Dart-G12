import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'main_screen.dart'; // Importa la pantalla principal

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      nextScreen: const MainScreen(), 
      duration: 6000, 
      backgroundColor: const Color(0xFF050F2C),
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animation/mapa.json', height: 150), 
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: "Explor",
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: "Andes",
                  style: TextStyle(color: Color(0xFFEA1D5D)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Explore UniAndes Like Never Before",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
      splashIconSize: 250, // Tamaño total del splash
      splashTransition: SplashTransition.fadeTransition, // Efecto de transición
    );
  }
}

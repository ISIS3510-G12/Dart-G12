import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // 🔹 Callback opcional para manejar el toque

  const CategoryIcon({
    required this.icon,
    required this.label,
    this.onTap, // Permite que sea opcional
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 📌 Ejecuta la función cuando se toque el icono
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 253, 253, 253).withOpacity(0.4), // Fondo blanco
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Borde azul oscuro
                  width: 1,
                ),

              ),
              child: Icon(
                icon,
                color: Colors.black, // Icono rosa
                size: 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold, // Texto en negrita
              ),
            ),
          ],
        ),
      ),
    );
  }
}


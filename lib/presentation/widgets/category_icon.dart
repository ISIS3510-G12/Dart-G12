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
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF2E1F54).withOpacity(0.3),
              child: Icon(icon, color: Color(0xFF050F2C)),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DistanceCard extends StatelessWidget {
  final double distance;
  final VoidCallback onStepsPressed;

  const DistanceCard({
    super.key,
    required this.distance,
    required this.onStepsPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula el tiempo en minutos (ejemplo: distancia/1000 * 7)
    final timeText = "${(distance / 1000 * 7).toStringAsFixed(0)} min";
    final distanceText = "(${distance.toStringAsFixed(0)} m)";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: [
                TextSpan(
                  text: "$timeText ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: distanceText,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Cl. 19A #1e-37, Bogotá",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onPressed: onStepsPressed,
            icon: const Icon(Icons.list, color: Colors.white),
            label: const Text("Steps", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

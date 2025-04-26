import 'package:flutter/material.dart';
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget destinationScreen;
  final bool showSeeAll;

  const SectionHeader({
    required this.title,
    required this.destinationScreen,
    this.showSeeAll = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (showSeeAll) // 👈 solo muestra el botón si showSeeAll es true
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen),
                );
              },
              child: const Text(
                "See all",
                style: TextStyle(fontSize: 14, color: Color(0xFFEA1D5D)),
              ),
            ),
        ],
      ),
    );
  }
}

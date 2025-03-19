import 'package:flutter/material.dart';

class StepsCard extends StatelessWidget {
  final VoidCallback onClose;

  const StepsCard({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Row(
              children: const [
                Icon(Icons.chevron_left, color: Color(0xFFEA1D5D), size: 45),
                Text(
                  "Steps",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA1D5D)),
                ),
              ],
            ),
          ),
          const ListTile(
              leading: Icon(Icons.circle, color: Colors.pink),
              title: Align(alignment: Alignment.centerLeft, child: Text("Bloque C"))),
          const ListTile(
              leading: Icon(Icons.circle, color: Colors.black),
              title: Align(alignment: Alignment.centerLeft, child: Text("Bloque W (quinto piso)"))),
          const ListTile(
              leading: Icon(Icons.circle, color: Colors.green),
              title: Align(alignment: Alignment.centerLeft, child: Text("Bloque ML"))),
        ],
      ),
    );
  }
}

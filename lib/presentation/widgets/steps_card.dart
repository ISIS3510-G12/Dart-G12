import 'package:flutter/material.dart';

class StepsCard extends StatelessWidget {
  final VoidCallback onClose;
  final List<Map<String, dynamic>> nodes;

  const StepsCard({
    super.key,
    required this.onClose,
    required this.nodes,
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
                    color: Color(0xFFEA1D5D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 300, // 👈 Ajusta esto según el espacio que quieras ocupar
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = nodes[index];
                final nodeName = node['node_name'] ?? 'Paso ${index + 1}';

                Color color;
                if (index == 0) {
                  color = Colors.pink;
                } else if (index == nodes.length - 1) {
                  color = Colors.green;
                } else {
                  color = Colors.black;
                }

                return ListTile(
                  leading: Icon(Icons.circle, color: color),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(nodeName),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

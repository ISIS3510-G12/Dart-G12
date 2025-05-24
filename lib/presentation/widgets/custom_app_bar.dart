import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget dropdownFrom;
  final Widget dropdownTo;
  final VoidCallback onSwap;
  final VoidCallback onMoreOptions;

  const CustomAppBar({
    super.key,
    required this.dropdownFrom,
    required this.dropdownTo,
    required this.onSwap,
    required this.onMoreOptions,
  });

  // Widget para la línea punteada
  Widget _buildDottedLine(double height) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          const dashHeight = 3.0;
          const dashSpace = 2.0;
          final dashCount = (totalHeight / (dashHeight + dashSpace)).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dashCount, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: dashSpace),
                child: Container(
                  width: 1,
                  height: dashHeight,
                  color: Colors.grey,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      toolbarHeight: 130,
      automaticallyImplyLeading: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna de íconos con línea punteada
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fiber_manual_record, color: Colors.blue, size: 20),
              _buildDottedLine(30),
              const Icon(Icons.location_on, color: Colors.red, size: 20),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fila 1: Dropdown "Your Location" y botón de más opciones
                Row(
                  children: [
                    Expanded(child: dropdownFrom),
                  ],
                ),
                const SizedBox(height: 8),
                // Fila 2: Dropdown "Destination" y botón para swap
                Row(
                  children: [
                    Expanded(child: dropdownTo),
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Colors.black),
                      onPressed: onSwap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

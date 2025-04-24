import 'package:dart_g12/presentation/views/see_all_screen.dart';
import 'package:flutter/material.dart';
import 'category_icon.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          CategoryIcon(
            icon: Icons.business,
            label: "Buildings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen(
                    contentType: "building",
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16), // Espacio entre íconos
          CategoryIcon(
            icon: Icons.event,
            label: "Events",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen(
                    contentType: "event",
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          const CategoryIcon(
            icon: Icons.school,
            label: "Study Spaces",
          ),
          const SizedBox(width: 16),
          CategoryIcon(
            icon: Icons.build,
            label: "Laboratories",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen(
                    contentType: "laboratory",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

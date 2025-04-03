import 'package:dart_g12/presentation/views/see_all_screen.dart';
import 'package:flutter/material.dart';
import 'category_icon.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryIcon(
            icon: Icons.business,
            label: "Buildings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen()
                ),
              );
            },
          ),
          const CategoryIcon(icon: Icons.event, label: "Events"),
          const CategoryIcon(icon: Icons.restaurant, label: "Food & Rest"),
          const CategoryIcon(icon: Icons.school, label: "Study Spaces"),
          const CategoryIcon(icon: Icons.build, label: "Services"),
        ],
      ),
    );
  }
}

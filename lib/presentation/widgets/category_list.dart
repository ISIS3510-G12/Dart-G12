import 'package:flutter/material.dart';
import 'category_icon.dart';  // Asegúrate de que este archivo esté importado

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView(
      
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryIcon(icon: Icons.business, label: "Buildings"),
          CategoryIcon(icon: Icons.event, label: "Events"),
          CategoryIcon(icon: Icons.restaurant, label: "Food & Rest"),
          CategoryIcon(icon: Icons.school, label: "Study Spaces"),
          CategoryIcon(icon: Icons.build, label: "Services"),
        ],
      ),
    );
  }
}

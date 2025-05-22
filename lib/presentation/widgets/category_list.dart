import 'package:dart_g12/presentation/views/see_all_screen.dart';
import 'package:flutter/material.dart';
import 'category_icon.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.business, "label": "Buildings", "type": "building"},
      {"icon": Icons.event, "label": "Events", "type": "event"},
      {"icon": Icons.school, "label": "Auditoriums", "type": "auditorium"},
      {"icon": Icons.build, "label": "Laboratories", "type": "laboratory"},
      {"icon": Icons.library_books, "label": "Libraries", "type": "library"},
      {"icon": Icons.miscellaneous_services, "label": "Services", "type": "services"},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = constraints.maxWidth / categories.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: categories.map((category) {
            return SizedBox(
              width: itemWidth,
              child: CategoryIcon(
                icon: category["icon"] as IconData,
                label: category["label"] as String,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllScreen(
                        contentType: category["type"] as String,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

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
      {"icon": Icons.account_balance, "label": "Faculties", "type": "faculty"},
    ];

    return SizedBox(
      height: 100, // ajusta la altura si es necesario
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        ),
      ),
    );
  }
}

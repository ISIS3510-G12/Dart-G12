import 'package:dart_g12/views/profile_page.dart';
import 'package:flutter/material.dart';
import '../views/pagina1.dart';
import '../views/pagina2.dart';
import '../widgets/BottomNavbar.dart';
import '../views/map_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Pagina1(),
    const Pagina2(),
    const Pagina1(),
    const Pagina2(),
    const ProfilePage(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

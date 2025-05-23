import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/views/profile_page.dart';
import 'package:dart_g12/presentation/views/see_all_screen.dart';
import 'package:dart_g12/presentation/views/notificacion_page.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:dart_g12/presentation/views/map_page.dart';
import 'package:dart_g12/presentation/views/home_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    SeeAllScreen(contentType: "favorite"),
    MapPage(),
    NotificacionPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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

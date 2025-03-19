import 'package:dart_g12/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

}
class _ProfilePageState extends State<ProfilePage> {

  // get auth service
  final authService = AuthService();

  // log out button pressed
  void logout() async {
    await authService.signOut();

  }

  @override
  Widget build(BuildContext context) {

    // get user email
    final currentEmail = authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // log out button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Text(currentEmail.toString()),
      ),
    );
  }
}
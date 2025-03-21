import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_g12/presentation/view_models/profile_view_model.dart';
import '../widgets/ovals_painter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
                Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Account',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 120),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage('https://placekitten.com/200/200'),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.currentUsername ?? 'User',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Student',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.edit, 'Edit profile'),
                          _buildMenuItem(Icons.language, 'Language'),
                          _buildMenuItem(Icons.notifications, 'Notifications'),
                          _buildMenuItem(Icons.logout, 'Sign out', 
                            onTap: () => viewModel.logout()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      onTap: onTap,
    );
  }
}

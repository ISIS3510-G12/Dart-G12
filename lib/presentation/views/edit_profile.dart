import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/ovals_painter.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late EditProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = EditProfile();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _profile.loadUserData();
    setState(() {
      nameController.text = _profile.name;
      lastNameController.text = _profile.lastName;
      emailController.text = _profile.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OvalsPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profile.avatarUrl.isNotEmpty
                        ? NetworkImage(_profile.avatarUrl)
                        : AssetImage('assets/cat.jpg') as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          nameController.text = _profile.name;
                          lastNameController.text = _profile.lastName;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _profile.updateProfile(
                            nameController.text,
                            lastNameController.text,
                          );

                          if (passwordController.text.isNotEmpty) {
                            await _profile
                                .changePassword(passwordController.text);

                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Contraseña actualizada'),
                                  content: const Text(
                                    'Por seguridad, necesitas volver a iniciar sesión.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cierra el diálogo
                                        Navigator.of(context)
                                            .maybePop(); // Regresa a la pantalla anterior
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile updated")),
                          );
                        },
                        child: const Text('Save changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _profile.selectedIndex,
        onTap: (index) => _profile.onItemTapped(context, index),
      ),
    );
  }
}

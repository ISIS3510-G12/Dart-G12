import 'dart:io';

import 'package:dart_g12/presentation/views/started_page.dart';
import 'package:dart_g12/presentation/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/ovals_painter.dart';

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
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

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

  Future<void> _pickAndUploadImage() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    final file = File(pickedFile.path);

    await _profile.saveAvatarPath(file.path); // ← Guardamos localmente

    setState(() {
      _profile.avatarPath = file.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar actualizado')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profile.avatarPath.isNotEmpty
                          ? FileImage(File(_profile.avatarPath))
                          : const AssetImage('assets/cat.jpg') as ImageProvider,
                      ),
                      if (_isUploading)
                        const CircularProgressIndicator(),
                      if (!_isUploading)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                          try {
                            await _profile.changePassword(passwordController.text);

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
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const WelcomePage(),
                                          ),
                                        );
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return;
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _profile.traducirError(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile updated")),
                        );
                      },
                        child: const Text('Save changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
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

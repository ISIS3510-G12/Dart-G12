import 'dart:io';

import 'package:dart_g12/presentation/views/started_page.dart';
import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dart_g12/presentation/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EditProfile with ChangeNotifier {
  final _supabase = SupabaseService().client;

  String _name = '';
  String _lastName = '';
  String _email = '';
  String _avatarUrl = '';
  int _selectedIndex = 4;

  int get selectedIndex => _selectedIndex;
  String get name => _name;
  String get lastName => _lastName;
  String get email => _email;
  String get avatarUrl => _avatarUrl;
  String avatarPath = '';

  // Cargar los datos del usuario desde la metadata
  Future<void> loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata ?? {};
      _name = (metadata['display_name'] ?? '').split(' ').first;
      _lastName = (metadata['display_name'] ?? '').split(' ').last;
      _avatarUrl = metadata['avatar_url'] ?? '';
      final prefs = await SharedPreferences.getInstance();
      avatarPath = prefs.getString('avatar_path') ?? '';
      _email = user.email ?? '';
      notifyListeners();
    }
  }

  set avatarUrl(String url) {
    _avatarUrl = url;
  }

  // Actualizar el perfil con el nombre y apellido
  Future<void> updateProfile(String name, String lastName) async {
    final displayName = '$name $lastName';
    await _updateUserMetadata({'display_name': displayName});
    _name = name;
    _lastName = lastName;
    notifyListeners();
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Si no retorna usuario, algo falló
      if (response.user == null) {
        throw Exception('No se pudo cambiar la contraseña.');
      }

      // (Opcional) Cierra sesión para forzar re-login
      await _supabase.auth.signOut();
      notifyListeners();
    } on AuthException catch (e) {
      // Errores específicos de Supabase
      String mensaje = traducirError(e.message);
      throw Exception(mensaje);
    } catch (e) {
      // Cualquier otro error inesperado
      throw Exception('Ocurrió un error: $e');
    }
  }


  // Actualizar los metadatos del usuario en Supabase
  Future<void> _updateUserMetadata(Map<String, dynamic> data) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _supabase.auth.updateUser(UserAttributes(data: data));
    } else {
      // Opcional: puedes manejar el caso sin internet aquí
      print('No hay conexión a Internet. No se actualizó el usuario.');
    }
  }

  Future<void> updateAvatarUrl(String newAvatarUrl) async {
    await _updateUserMetadata({'avatar_url': newAvatarUrl});
    _avatarUrl = newAvatarUrl;
    notifyListeners();
  }

    Future<String?> uploadAvatarImage(File imageFile) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return null;

    final fileExt = imageFile.path.split('.').last;
    final filePath = 'avatars/$userId/avatar.$fileExt';

    try {
      final storageResponse = await supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('avatars').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }


  Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
    avatarPath = path;
  }

  String traducirError(String mensajeOriginal) {
    if (mensajeOriginal.contains('at least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    } else if (mensajeOriginal.contains('same_password')) {
      return 'La nueva contraseña debe ser diferente a la anterior.';
    } else {
      return mensajeOriginal;
    }
  }


  void onItemTapped(BuildContext context, int index) {
    _selectedIndex = index;
    notifyListeners();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile with ChangeNotifier {
  final _supabase = SupabaseService().client;

  String _name = '';
  String _lastName = '';
  String _email = '';
  String _avatarUrl = '';

  String get name => _name;
  String get lastName => _lastName;
  String get email => _email;
  String get avatarUrl => _avatarUrl;

  // Cargar los datos del usuario desde la metadata
  Future<void> loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata ?? {};
      _name = (metadata['display_name'] ?? '').split(' ').first;
      _lastName = (metadata['display_name'] ?? '').split(' ').last;
      _avatarUrl = metadata['avatar_url'] ?? '';
      _email = user.email ?? '';
      notifyListeners();
    }
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

      // Comprobar si el usuario es null para detectar errores
      if (response.user == null) {
        throw Exception('No se pudo cambiar la contraseña.');
      }

      // (Opcional) Cierra sesión si quieres forzar re-login
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Error al cambiar la contraseña: $e');
      rethrow; // para propagar el error si es necesario
    }
  }

  // Actualizar los metadatos del usuario en Supabase
  Future<void> _updateUserMetadata(Map<String, dynamic> data) async {
    await _supabase.auth.updateUser(UserAttributes(data: data));
  }
}

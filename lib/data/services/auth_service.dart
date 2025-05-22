import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = SupabaseService().client;

  // Sign in with email and password

  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  // Sign up with email and password

  Future<void> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName}, // Guardamos el nombre en Supabase
    );
  }

  // Sign out

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email

  String? getCurrentUsername() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.userMetadata?['display_name'];
  }

Future<String?> getUserAvatar() async {
  final prefs = await SharedPreferences.getInstance();
  final path = prefs.getString('avatar_path');
  return (path != null && path.isNotEmpty) ? path : null;
}

}
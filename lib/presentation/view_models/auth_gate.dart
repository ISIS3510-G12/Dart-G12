import 'package:dart_g12/presentation/views/main_screen.dart';
import 'package:dart_g12/presentation/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      

      // Build appropiate page based on auth state
      builder: (context, snapshot) {
        // loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // check if there is a valid session
        final session = snapshot.hasData? snapshot.data!.session : null;

        if (session != null) {
          return const MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
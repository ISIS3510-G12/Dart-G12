import 'package:dart_g12/presentation/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dart_g12/presentation/view_models/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cdvdebibeggycjaeypck.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkdmRlYmliZWdneWNqYWV5cGNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzYxNTEsImV4cCI6MjA1NzkxMjE1MX0.bUhJdVbWwo018EzJfEdkHuK6ZqaTrXlys07Kb6CTTFM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
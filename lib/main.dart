import 'package:dart_g12/views/auth_gate.dart';
import 'package:flutter/material.dart';
//import 'views/MainScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
     

void main() async{

  // supabase setup
  await Supabase.initialize(
    url: 'https://cdvdebibeggycjaeypck.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkdmRlYmliZWdneWNqYWV5cGNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzYxNTEsImV4cCI6MjA1NzkxMjE1MX0.bUhJdVbWwo018EzJfEdkHuK6ZqaTrXlys07Kb6CTTFM',

  );
    
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),

      
      
    );
  }
  }
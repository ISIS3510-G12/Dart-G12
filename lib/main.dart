import 'package:dart_g12/presentation/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dart_g12/presentation/views/started_page.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cdvdebibeggycjaeypck.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkdmRlYmliZWdneWNqYWV5cGNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzYxNTEsImV4cCI6MjA1NzkxMjE1MX0.bUhJdVbWwo018EzJfEdkHuK6ZqaTrXlys07Kb6CTTFM',
  );

  final config = PostHogConfig('phx_doPSkw2mt705QFJg38ru3XsAh77ulHN0NMRnThadLkU5u91');
  config.debug = true;
  config.captureApplicationLifecycleEvents = true;
  config.host = 'https://us.i.posthog.com';
  await Posthog().setup(config);
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
        '/': (context) => const WelcomePage(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
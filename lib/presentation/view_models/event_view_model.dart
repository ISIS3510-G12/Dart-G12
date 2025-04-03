import 'package:flutter/material.dart';
import '../../data/repositories/event_repository.dart';
import '../views/main_screen.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository repository = EventRepository();
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  EventViewModel();

  /// Getters
  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  /// Método para obtener los eventos desde Supabase
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await repository.fetchEvents();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Método para actualizar el índice seleccionado y navegar a `MainScreen`
  void onItemTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;

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

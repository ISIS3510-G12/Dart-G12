import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/event_repository.dart'; // Importa tu repository de eventos
import '../views/main_screen.dart';

class SeeAllViewModel extends ChangeNotifier {
  final LocationRepository locationRepository = LocationRepository();
  final EventRepository eventRepository = EventRepository(); // Asegúrate de tener esto

  late String contentType;
  List<Map<String, dynamic>> _items = []; // Para almacenar tanto edificios como eventos
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  SeeAllViewModel();

  // Getters
  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  // Método para obtener los edificios desde Supabase
  Future<void> fetchBuildings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await locationRepository.fetchBuildings(); // Cambié _buildings por _items
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Método para obtener los eventos desde Supabase
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await eventRepository.fetchEvents(); // Cambié _buildings por _items
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Método común para cargar datos dependiendo del tipo de contenido
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (contentType == 'building') {
        await fetchBuildings();
      } else if (contentType == 'event') {
        await fetchEvents();
      } else {
        _error = 'Tipo de contenido no soportado: $contentType';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Método para actualizar el índice seleccionado y navegar a `MainScreen`
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

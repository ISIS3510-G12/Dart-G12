import 'package:dart_g12/data/repositories/auditoriums_repository.dart';
import 'package:dart_g12/data/repositories/favorite_repository.dart';
import 'package:dart_g12/data/repositories/laboratories_repository.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../views/main_screen.dart';
import '../../data/repositories/access_repository.dart';

class SeeAllViewModel extends ChangeNotifier {
  final LocationRepository locationRepository = LocationRepository();
  final EventRepository eventRepository = EventRepository();
  final LaboratoriesRepository laboratoriesRepository =LaboratoriesRepository();
  final AccessRepository accessRepository = AccessRepository();
  final FavoriteRepository favoriteRepository = FavoriteRepository();
  final AuditoriumRepository auditoriumRepository = AuditoriumRepository();

  late String contentType;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _items = [];
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
      _allItems = await locationRepository
          .fetchBuildings(); // Cambié _buildings por _items
      _items = List.from(_allItems);
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
      _allItems =
          await eventRepository.fetchEvents(); // Cambié _buildings por _items
      _items = List.from(_allItems);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Método para obtener los eventos desde Supabase
  Future<void> fetchLaboratories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await laboratoriesRepository.fetchLaboratories();
      _items = List.from(_allItems);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Método para obtener los access points desde Supabase
  Future<void> fetchAccess() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await accessRepository.fetchAccess();
      _items = List.from(_allItems);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final favorites = await favoriteRepository.getFavorites();
      _items = List.from(favorites);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAuditoriums() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await auditoriumRepository.fetchAuditoriums();
      _items = List.from(_allItems);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (contentType == 'building') {
        await fetchBuildings();
      } else if (contentType == 'event') {
        await fetchEvents();
      } else if (contentType == 'laboratory') {
        await fetchLaboratories();
      } else if (contentType == 'access') {
        await fetchAccess(); 
      } else if (contentType == 'favorite') {
        await fetchFavorites();
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

  void filterItems(String query) {
    if (query.trim().isEmpty) {
      _items = List.from(_allItems);
    } else {
      final q = query.toLowerCase();
      _items = _allItems.where((item) {
        final text =
            (item['title'] ?? item['name'] ?? '').toString().toLowerCase();
        return text.contains(q);
      }).toList();
    }
    notifyListeners();
  }
}

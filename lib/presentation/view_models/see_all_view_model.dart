import 'package:dart_g12/data/repositories/auditoriums_repository.dart';
import 'package:dart_g12/data/repositories/favorite_repository.dart';
import 'package:dart_g12/data/repositories/laboratories_repository.dart';
import 'package:dart_g12/data/repositories/libraries_repository.dart';
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
  final LibraryRepository libraryRepository = LibraryRepository();

  late String contentType;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;
  String? _selectedBlock;
  String? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate; 

  SeeAllViewModel();

  // Getters
  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;
  String? get selectedBlock => _selectedBlock;
  String? get selectedLocation => _selectedLocation;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

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

  Future<void> fetchLibraries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await libraryRepository.fetchLibraries();
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
      } else if (contentType == 'auditorium') {
        await fetchAuditoriums();
      } else if (contentType == 'library') {
        await fetchLibraries();
      
      } else if (contentType == 'none') {
        _items = List.from(_allItems);
      }
      else {
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

  void filterByLocation(String location) {
  _items = _allItems.where((item) {
    final itemLocation = (item['locations']?['name'] ?? '').toLowerCase();
    return itemLocation.contains(location.toLowerCase());
  }).toList();
  notifyListeners();
}

void filterByDate(DateTime startDate, DateTime endDate) {
  _items = _allItems.where((item) {
    final startTime = DateTime.parse(item['start_time']);
    final endTime = DateTime.parse(item['end_time']);
    return startTime.isAfter(startDate) && endTime.isBefore(endDate);
  }).toList();
  notifyListeners();
}

void setSelectedBlock(String? block) {
  _selectedBlock = block;
  notifyListeners();
}
void setSelectedLocation(String? location) {
  _selectedLocation = location;
  notifyListeners();
}
void setStartDate(DateTime? startDate) {
  _startDate = startDate;
  notifyListeners();
}
void setEndDate(DateTime? endDate) {
  _endDate = endDate;
  notifyListeners();
}

void clearFilters() {
  _selectedBlock = null;
  _selectedLocation = null;
  _startDate = null;
  _endDate = null;
  notifyListeners();
}

String formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}


}

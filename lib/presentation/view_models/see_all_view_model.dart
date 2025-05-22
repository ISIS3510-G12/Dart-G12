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
  //String? favoriteType;
  //String? selectedLocation;
  String? selectedBlock;
  //DateTime? startDate;
  //DateTime? endDate;
  // temporales para filtrar
  String? tempFavoriteType;
  String? tempSelectedLocation;
  DateTime? tempStartDate;
  DateTime? tempEndDate;

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
            (item['name'] ?? '').toString().toLowerCase();
        return text.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void setFavoriteType(String? type) {
    tempFavoriteType = type;
    notifyListeners();
  }

  void setSelectedLocation(String? location) {
    tempSelectedLocation = location;
    notifyListeners();
  }

  void setSelectedBlock(String? block) {
    selectedBlock = block;
    if (block == null || block.isEmpty) {
      _items = List.from(_allItems);
    } else {
      _items = _allItems.where((item) {
        final b = item['block'] ?? item['locations']?['block'];
        return b != null && b.toString().toLowerCase().contains(block.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    tempStartDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    tempEndDate = date;
    notifyListeners();
  }

  void applyAllFilters(String query) {
  // 1. Filtro por nombre
  var filtered = _allItems.where((item) {
    final name = (item['name'] ??'').toString().toLowerCase();
    final block = (item['block'] ??'').toString().toLowerCase();
    return name.contains(query.toLowerCase()) || block.contains(query.toLowerCase());
  }).toList();

  // 2. Filtro por tipo favorito
  if (tempFavoriteType != null && tempFavoriteType!.isNotEmpty) {
    filtered = filtered.where((item) =>
      (item['type'] ?? '').toString().toLowerCase() == tempFavoriteType!.toLowerCase()
    ).toList();
  }

  // 3. Filtro por ubicación
  if (tempSelectedLocation != null && tempSelectedLocation!.isNotEmpty) {
    filtered = filtered.where((item) {
      final locName = item['locations']?['name'] ?? item['location'] ?? '';
      return locName.toString().toLowerCase().contains(tempSelectedLocation!.toLowerCase());
    }).toList();
  }

  // 4. Filtro por fechas
  if (tempStartDate != null || tempEndDate != null) {
    filtered = filtered.where((item) {
      final eventDateStr = item['date'] ?? item['start_date'];
      if (eventDateStr == null) return false;
      final eventDate = DateTime.tryParse(eventDateStr.toString());
      if (eventDate == null) return false;
      final afterStart = tempStartDate == null || eventDate.isAfter(tempStartDate!) || eventDate.isAtSameMomentAs(tempStartDate!);
      final beforeEnd = tempEndDate == null || eventDate.isBefore(tempEndDate!) || eventDate.isAtSameMomentAs(tempEndDate!);
      return afterStart && beforeEnd;
    }).toList();
  }

  _items = filtered;
  notifyListeners();
}

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  } 

  void clearAllFilters() {
    tempFavoriteType = null;
    tempSelectedLocation = null;
    tempStartDate = null;
    tempEndDate = null;
    notifyListeners();
  }
// ...existing code...


}

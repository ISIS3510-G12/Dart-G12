import 'package:dart_g12/data/repositories/auditoriums_repository.dart';
import 'package:dart_g12/data/repositories/favorite_repository.dart';
import 'package:dart_g12/data/repositories/laboratories_repository.dart';
import 'package:dart_g12/data/repositories/libraries_repository.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../views/main_screen.dart';
import '../../data/repositories/access_repository.dart';
import '../../data/repositories/services_repository.dart';
import 'package:dart_g12/data/repositories/faculties_repository.dart';

class SeeAllViewModel extends ChangeNotifier {
  final LocationRepository locationRepository = LocationRepository();
  final EventRepository eventRepository = EventRepository();
  final LaboratoriesRepository laboratoriesRepository =LaboratoriesRepository();
  final AccessRepository accessRepository = AccessRepository();
  final FavoriteRepository favoriteRepository = FavoriteRepository();
  final AuditoriumRepository auditoriumRepository = AuditoriumRepository();
  final LibraryRepository libraryRepository = LibraryRepository();
  final ServicesRepository servicesRepository = ServicesRepository();
  final FacultyRepository facultiesRepository = FacultyRepository();

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

    // Método para obtener los eventos desde Supabase
  Future<void> fetchFaculties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await facultiesRepository.fetchFaculties();
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


Future<void> fetchServices() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _allItems = await servicesRepository.fetchServices();
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
      } else if (contentType == 'service') {
        await fetchServices();
      } else if (contentType == 'faculty') {
        await fetchFaculties();
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

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  } 

// =======================================================
// =============== FILTER METHODS SECTION ================
// =======================================================

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

  void applyAllFilters(String query) {
  // 1. Filtro por nombre
  var filtered = _allItems.where((item) {
    final name = (item['name'] ?? '').toString().toLowerCase();
    final block = (item['block'] ?? '').toString().toLowerCase();
    return name.contains(query.toLowerCase()) || block.contains(query.toLowerCase());
  }).toList();

  // 2. Filtro por tipo favorito TODO arreglar por como funcionan los favoritos
  if (tempFavoriteType != null && tempFavoriteType!.isNotEmpty) {
    filtered = filtered.where((item) {
      return (item['type'] ?? '').toString().toLowerCase() ==
          tempFavoriteType!.toLowerCase();
    }).toList();

  }

  // 3. Filtro por ubicación
  if (tempSelectedLocation != null && tempSelectedLocation!.isNotEmpty) {
    filtered = filtered.where((item) {
      final locName = item['locations']?['name'] ?? '';
      final locBlock = item['locations']?['block'] ?? '';
      return locName.toString().toLowerCase().contains(tempSelectedLocation!.toLowerCase()) || 
        locBlock.toString().toLowerCase().contains(tempSelectedLocation!.toLowerCase());
    }).toList();
  }

  // 4. Date filter: custom logic for start/end
  if (tempStartDate != null || tempEndDate != null) {
  // Si solo hay fecha de inicio, la fecha de fin es 2030
    final start = tempStartDate ?? DateTime(2020, 1, 1);
    final end = tempEndDate ?? DateTime(2030, 12, 31);

    filtered = filtered.where((item) {
      final startStr = item['start_time'];
      final endStr = item['end_time'];
      if (startStr == null || endStr == null) return false;

      final eventStart = DateTime.tryParse(startStr.toString());
      final eventEnd = DateTime.tryParse(endStr.toString());
      if (eventStart == null || eventEnd == null) return false;

      // El evento debe empezar después o igual a start y terminar antes o igual a end
      return (eventStart.isAfter(start) || eventStart.isAtSameMomentAs(start)) &&
           (eventEnd.isBefore(end) || eventEnd.isAtSameMomentAs(end));
    }).toList();
}

    _items = filtered;
    notifyListeners();
}


  void clearAllFilters() {
    tempFavoriteType = null;
    tempSelectedLocation = null;
    tempStartDate = null;
    tempEndDate = null;
    notifyListeners();
  }

}

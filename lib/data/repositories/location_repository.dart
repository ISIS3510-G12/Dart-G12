import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService cache = LocalStorageService();

  LocationRepository();

  /// Obtener todas las ubicaciones y ordenarlas por proximidad al usuario
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    const cacheKey = 'all_locations_sorted';
    List<Map<String, dynamic>> locations = [];

    // 1. Intento leer de cache
    try {
      locations = await cache.fetch(cacheKey);
      if (locations.isNotEmpty) {
        // Si hay cache, devuelvo enseguida y refresco en background
        unawaited(_fetchAndCacheLocationsSorted(cacheKey));
        return locations;
      }
    } catch (_) {
      // ignorar error de cache
    }

    // 2. Cache vacía o fallo: obtengo datos remotos
    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block');

    if (response.isEmpty) throw Exception('No se encontraron ubicaciones.');

    locations = List<Map<String, dynamic>>.from(response);

    // 3. Chequeo si el servicio de ubicación está activo
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );
      final userLat = pos.latitude;
      final userLon = pos.longitude;

      locations.sort((a, b) {
        final distA = Geolocator.distanceBetween(
            userLat, userLon, a['latitude'], a['longitude']);
        final distB = Geolocator.distanceBetween(
            userLat, userLon, b['latitude'], b['longitude']);
        return distA.compareTo(distB);
      });
    }
    // 4. Guardo en cache y devuelvo
    await cache.save(cacheKey, locations);
    return locations;
  }

  Future<void> _fetchAndCacheLocationsSorted(String cacheKey) async {
    try {
      final response = await supabase
          .from('locations')
          .select('location_id, name, description, latitude, longitude, image_url, block');
      var list = List<Map<String, dynamic>>.from(response);

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
        );
        final userLat = pos.latitude;
        final userLon = pos.longitude;
        list.sort((a, b) {
          final distA = Geolocator.distanceBetween(
              userLat, userLon, a['latitude'], a['longitude']);
          final distB = Geolocator.distanceBetween(
              userLat, userLon, b['latitude'], b['longitude']);
          return distA.compareTo(distB);
        });
      }

      await cache.save(cacheKey, list);
    } catch (_) {
      // fallamos silenciosamente
    }
  }

  /// Obtener ubicaciones (todos los edificios)
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    const cacheKey = 'buildings';
    List<Map<String, dynamic>> buildings = [];

    // 1. Intento cache
    try {
      buildings = await cache.fetch(cacheKey);
      if (buildings.isNotEmpty) {
        unawaited(_fetchAndCacheBuildings(cacheKey));
        return buildings;
      }
    } catch (_) {}

    // 2. Fetch remoto
    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block');
    if (response.isEmpty) throw Exception('No se encontraron ubicaciones.');

    buildings = List<Map<String, dynamic>>.from(response);

    // 3. Condicional sort por proximidad
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final userLat = pos.latitude;
      final userLon = pos.longitude;
      buildings.sort((a, b) {
        final distA = Geolocator.distanceBetween(
            userLat, userLon, a['latitude'], a['longitude']);
        final distB = Geolocator.distanceBetween(
            userLat, userLon, b['latitude'], b['longitude']);
        return distA.compareTo(distB);
      });
    }

    await cache.save(cacheKey, buildings);
    return buildings;
  }

  Future<void> _fetchAndCacheBuildings(String cacheKey) async {
    try {
      final response = await supabase
          .from('locations')
          .select('location_id, name, description, latitude, longitude, image_url, block');
      var list = List<Map<String, dynamic>>.from(response);

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final userLat = pos.latitude;
        final userLon = pos.longitude;
        list.sort((a, b) {
          final distA = Geolocator.distanceBetween(
              userLat, userLon, a['latitude'], a['longitude']);
          final distB = Geolocator.distanceBetween(
              userLat, userLon, b['latitude'], b['longitude']);
          return distA.compareTo(distB);
        });
      }

      await cache.save(cacheKey, list);
    } catch (_) {}
  }

  /// Obtener una ubicación por su ID
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final cacheKey = 'location_$id';

    try {
      final cached = await cache.fetch(cacheKey);
      if (cached.isNotEmpty) return cached.first;
    } catch (_) {}

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block')
        .eq('location_id', id)
        .maybeSingle();

    if (response != null) {
      await cache.save(cacheKey, [response]);
    }
    return response;
  }

  /// Obtener ubicaciones con paginación
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(
      int page, int limit) async {
    final cacheKey = 'locations_page_$page';
    List<Map<String, dynamic>> paginated = [];

    try {
      paginated = await cache.fetch(cacheKey);
      if (paginated.isNotEmpty) return paginated;
    } catch (_) {}

    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block')
        .range(start, end);

    paginated = List<Map<String, dynamic>>.from(response);
    await cache.save(cacheKey, paginated);
    return paginated;
  }
}

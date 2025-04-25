import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService cache = LocalStorageService();

  LocationRepository();

  /// Obtiene y ordena todas las ubicaciones por cercanía
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    const cacheKey = 'all_locations_sorted';

    try {
      final cached = await cache.fetch(cacheKey);
      if (cached.isNotEmpty) {
        unawaited(_fetchAndCacheLocationsSorted(cacheKey));
        return cached;
      }
    } catch (_) {}

    final response = await _fetchLocationsFromRemote();
    final sorted = await _sortByProximity(response);

    await cache.save(cacheKey, sorted);
    return sorted;
  }

  Future<void> _fetchAndCacheLocationsSorted(String cacheKey) async {
    try {
      final response = await _fetchLocationsFromRemote();
      final sorted = await _sortByProximity(response);
      await cache.save(cacheKey, sorted);
    } catch (_) {}
  }

  /// Obtiene todas las ubicaciones que representan edificios
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    const cacheKey = 'buildings';

    try {
      final cached = await cache.fetch(cacheKey);
      if (cached.isNotEmpty) {
        unawaited(_fetchAndCacheBuildings(cacheKey));
        return cached;
      }
    } catch (_) {}

    final response = await _fetchLocationsFromRemote();
    final sorted = await _sortByProximity(response);

    await cache.save(cacheKey, sorted);
    return sorted;
  }

  Future<void> _fetchAndCacheBuildings(String cacheKey) async {
    try {
      final response = await _fetchLocationsFromRemote();
      final sorted = await _sortByProximity(response);
      await cache.save(cacheKey, sorted);
    } catch (_) {}
  }

  /// Obtiene una ubicación por su ID
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

  /// Obtiene ubicaciones con paginación
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(int page, int limit) async {
    final cacheKey = 'locations_page_$page';

    try {
      final cached = await cache.fetch(cacheKey);
      if (cached.isNotEmpty) return cached;
    } catch (_) {}

    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block')
        .range(start, end);

    final result = List<Map<String, dynamic>>.from(response);
    await cache.save(cacheKey, result);
    return result;
  }

  /// --- Helpers privados ---

  Future<List<Map<String, dynamic>>> _fetchLocationsFromRemote() async {
    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block');

    if (response.isEmpty) throw Exception('No se encontraron ubicaciones.');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> _sortByProximity(List<Map<String, dynamic>> locations) async {
    final position = await _getUserPosition();
    if (position == null) return locations;

    final userLat = position.latitude;
    final userLon = position.longitude;

    locations.sort((a, b) {
      final distA = Geolocator.distanceBetween(userLat, userLon, a['latitude'], a['longitude']);
      final distB = Geolocator.distanceBetween(userLat, userLon, b['latitude'], b['longitude']);
      return distA.compareTo(distB);
    });

    return locations;
  }

  Future<Position?> _getUserPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      return await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.best));
    } catch (_) {
      return null;
    }
  }
}

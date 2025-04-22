import 'dart:developer';
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
    final String cacheKey = 'all_locations_sorted';
    List<Map<String, dynamic>> locations = [];

    try {
      locations = await cache.fetch(cacheKey);
      if (locations.isNotEmpty) return locations;
    } catch (_) {}

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, image_url, category, latitude, longitude');

    if (response.isEmpty) throw Exception('No se encontraron ubicaciones.');

    locations = List<Map<String, dynamic>>.from(response);
    locations.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(userLat, userLon, a['latitude'], a['longitude']);
      double distanceB = Geolocator.distanceBetween(userLat, userLon, b['latitude'], b['longitude']);
      return distanceA.compareTo(distanceB);
    });

    await cache.save(cacheKey, locations);
    return locations;
  }

  /// Obtener ubicaciones donde category = 'Buildings'
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    const String cacheKey = 'buildings';
    List<Map<String, dynamic>> buildings = [];

    try {
      buildings = await cache.fetch(cacheKey);
      if (buildings.isNotEmpty) return buildings;
    } catch (_) {}

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, image_url, category, latitude, longitude')
        .eq('category', 'Buildings');

    if (response.isEmpty) throw Exception('No se encontraron edificios.');

    buildings = List<Map<String, dynamic>>.from(response);

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    buildings.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(userLat, userLon, a['latitude'], a['longitude']);
      double distanceB = Geolocator.distanceBetween(userLat, userLon, b['latitude'], b['longitude']);
      return distanceA.compareTo(distanceB);
    });

    await cache.save(cacheKey, buildings);
    return buildings;
  }

  /// Obtener una ubicación por su ID
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final String cacheKey = 'location_$id';

    try {
      final cached = await cache.fetch(cacheKey);
      if (cached.isNotEmpty) return cached.first;
    } catch (_) {}

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, image_url, category, latitude, longitude')
        .eq('location_id', id)
        .maybeSingle();

    if (response != null) {
      await cache.save(cacheKey, [response]);
    }

    return response;
  }

  /// Obtener ubicaciones con paginación
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(int page, int limit) async {
    final String cacheKey = 'locations_page_$page';
    List<Map<String, dynamic>> paginated = [];

    try {
      paginated = await cache.fetch(cacheKey);
      if (paginated.isNotEmpty) return paginated;
    } catch (_) {}

    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, image_url, category, latitude, longitude')
        .range(start, end);

    paginated = List<Map<String, dynamic>>.from(response);
    await cache.save(cacheKey, paginated);

    return paginated;
  }

  /// Obtener todos los lugares (`places`) de una `location` específica
  Future<List<Map<String, dynamic>>> fetchPlacesByLocation(int locationId) async {
    final String cacheKey = 'places_location_$locationId';
    List<Map<String, dynamic>> places = [];

    try {
      places = await cache.fetch(cacheKey);
      if (places.isNotEmpty) return places;
    } catch (_) {}

    final response = await supabase
        .from('places')
        .select('id, id_location, name, url_image, floor')
        .eq('id_location', locationId);

    if (response.isEmpty) throw Exception('No se encontraron lugares para esta ubicación.');

    places = List<Map<String, dynamic>>.from(response);
    await cache.save(cacheKey, places);

    return places;
  }
}

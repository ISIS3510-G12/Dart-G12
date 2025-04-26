import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

/// Helper para parsear la respuesta de Supabase.
List<Map<String, dynamic>> _parseList(List<dynamic> response) =>
    List<Map<String, dynamic>>.from(response);

/// Top-level: fetch + sort en un isolate.
Future<List<Map<String, dynamic>>> fetchAllLocationsSortedIsolate(
    dynamic _) async {
  final repo = LocationRepository._();
  final all = await repo._fetchLocationsFromRemote();
  return repo._sortByProximity(all);
}

/// (Opcional) Top-level para aislar solo el sort.
Future<List<Map<String, dynamic>>> sortByProximityIsolate(
    List<Map<String, dynamic>> locations) async {
  final repo = LocationRepository._();
  return repo._sortByProximity(locations);
}

class LocationRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService cache = LocalStorageService();

  // Constructor público
  LocationRepository();

  // Constructor interno para los isolates
  LocationRepository._();

  /// Obtiene y ordena todas las ubicaciones por cercanía
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    const cacheKey = 'all_locations_sorted';

    // Intentar cargar desde cache
    List<Map<String, dynamic>> cached = await _loadFromCache(cacheKey);
    if (cached.isNotEmpty) {
      // REFRESH en background
      unawaited(_fetchAndCacheLocationsSorted(cacheKey));
      return cached;
    }

    // Si no hay cache, delegamos todo a un isolate
    final sorted = await compute(fetchAllLocationsSortedIsolate, null);
    await cache.save(cacheKey, sorted);
    return sorted;
  }

  Future<void> _fetchAndCacheLocationsSorted(String cacheKey) async {
    try {
      final sorted = await compute(fetchAllLocationsSortedIsolate, null);
      await cache.save(cacheKey, sorted);
    } catch (e) {
      log('Error refrescando locations sorted: $e');
    }
  }

  /// Obtiene todas las ubicaciones que representan edificios
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    const cacheKey = 'buildings';

    // Intentar cargar desde cache
    List<Map<String, dynamic>> cached = await _loadFromCache(cacheKey);
    if (cached.isNotEmpty) {
      unawaited(_fetchAndCacheBuildings(cacheKey));
      return cached;
    }

    // Reutilizamos el mismo isolate de fetch+sort
    final sorted = await compute(fetchAllLocationsSortedIsolate, null);
    await cache.save(cacheKey, sorted);
    return sorted;
  }

  Future<void> _fetchAndCacheBuildings(String cacheKey) async {
    try {
      final sorted = await compute(fetchAllLocationsSortedIsolate, null);
      await cache.save(cacheKey, sorted);
    } catch (e) {
      log('Error refrescando buildings: $e');
    }
  }

  /// Obtiene una ubicación por su ID (no va en isolate, es rápida)
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final cacheKey = 'location_$id';

    List<Map<String, dynamic>> cached = await _loadFromCache(cacheKey);
    if (cached.isNotEmpty) return cached.first;

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

  /// Obtiene ubicaciones con paginación (no va en isolate)
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(int page, int limit) async {
    final cacheKey = 'locations_page_$page';

    List<Map<String, dynamic>> cached = await _loadFromCache(cacheKey);
    if (cached.isNotEmpty) return cached;

    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block')
        .range(start, end);

    final result = _parseList(response as List<dynamic>);
    await cache.save(cacheKey, result);
    return result;
  }

  /// Helpers privados

  Future<List<Map<String, dynamic>>> _loadFromCache(String cacheKey) async {
    try {
      return await cache.fetch(cacheKey);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLocationsFromRemote() async {
    final response = await supabase
        .from('locations')
        .select('location_id, name, description, latitude, longitude, image_url, block');

    if ((response as List).isEmpty) throw Exception('No se encontraron ubicaciones.');
    return _parseList(response);
  }

  Future<List<Map<String, dynamic>>> _sortByProximity(
      List<Map<String, dynamic>> locations) async {
    final position = await _getUserPosition();
    if (position == null) return locations;

    final userLat = position.latitude;
    final userLon = position.longitude;

    locations.sort((a, b) {
      final distA = Geolocator.distanceBetween(
          userLat, userLon, a['latitude'], a['longitude']);
      final distB = Geolocator.distanceBetween(
          userLat, userLon, b['latitude'], b['longitude']);
      return distA.compareTo(distB);
    });

    return locations;
  }

  Future<Position?> _getUserPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.best));
    } catch (_) {
      return null;
    }
  }
}

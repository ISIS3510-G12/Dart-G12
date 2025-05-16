import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class HomeRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  HomeRepository();

  Future<List<Map<String, dynamic>>> _fetchWithCache({
    required String cacheKey,
    required String table,
    required String selectQuery,
  }) async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache $cacheKey: $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase.from(table).select(selectQuery).limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error fetching $table from network: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheInBackground(
        cacheKey: cacheKey,
        table: table,
        selectQuery: selectQuery,
      ));
      return cached;
    }
  }

  Future<void> _fetchAndCacheInBackground({
    required String cacheKey,
    required String table,
    required String selectQuery,
  }) async {
    try {
      final response = await supabase.from(table).select(selectQuery).limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching $table from network (background): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocations() => _fetchWithCache(
        cacheKey: 'locations',
        table: 'locations',
        selectQuery: 'location_id, name, image_url, block',
      );

  Future<List<Map<String, dynamic>>> fetchMostSearchedLocations() => _fetchWithCache(
        cacheKey: 'mostSearchedLocations',
        table: 'most_popular_user_interactions',
        selectQuery: 'name, description, image_url, type, information_id, block',
      );

  Future<List<Map<String, dynamic>>> fetchLaboratories() => _fetchWithCache(
        cacheKey: 'laboratories',
        table: 'laboratories',
        selectQuery: 'laboratories_id, name, image_url, locations (name, block)',
      );

  Future<List<Map<String, dynamic>>> fetchAccess() => _fetchWithCache(
        cacheKey: 'accesses',
        table: 'access',
        selectQuery: 'access_id, name, image_url, locations (name, block)',
      );

  Future<List<Map<String, dynamic>>> fetchEvents() => _fetchWithCache(
        cacheKey: 'events',
        table: 'events',
        selectQuery: 'event_id, name, image_url, locations (name, block)',
      );

  Future<Map<String, List<Map<String, dynamic>>>> fetchAllData() async {
    final results = await Future.wait([
      fetchLocations(),
      fetchEvents(),
      fetchMostSearchedLocations(),
      fetchLaboratories(),
      fetchAccess(),
    ]);

    return {
      'locations': results[0],
      'events': results[1],
      'mostSearched': results[2],
      'laboratories': results[3],
      'access': results[4],
    };
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchEverythingInBackground(dynamic _) async {
    return await fetchAllData();
  }
}

Future<Map<String, List<Map<String, dynamic>>>> fetchAllDataIsolate(dynamic _) async {
  return await HomeRepository().fetchAllData();
}

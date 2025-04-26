import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

/// Helper to parse a dynamic list into a typed List<Map>.
List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class HomeRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  HomeRepository();

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('locations');
    } catch (e) {
      log('Error leyendo cache locations: \$e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('locations')
            .select('location_id, name, image_url, block')
            .limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save('locations', parsed);
        return parsed;
      } catch (e) {
        log('Error fetching locations from network: \$e');
        return cached;
      }
    } else {
      // Return cache immediately and refresh in background
      unawaited(_fetchAndCacheLocations());
      return cached;
    }
  }

  Future<void> _fetchAndCacheLocations() async {
    try {
      final response = await supabase
          .from('locations')
          .select('location_id, name, image_url, block')
          .limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('locations', parsed);
    } catch (e) {
      log('Error fetching locations from network (background): \$e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMostSearchedLocations() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('mostSearchedLocations');
    } catch (e) {
      log('Error leyendo cache most searched: \$e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('most_popular_user_interactions')
            .select('name, description, image_url, type, information_id, block')
            .limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save('mostSearchedLocations', parsed);
        return parsed;
      } catch (e) {
        log('Error fetching most searched from network: \$e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheMostSearchedLocations());
      return cached;
    }
  }

  Future<void> _fetchAndCacheMostSearchedLocations() async {
    try {
      final response = await supabase
          .from('most_popular_user_interactions')
          .select('name, description, image_url, type, information_id, block')
          .limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('mostSearchedLocations', parsed);
    } catch (e) {
      log('Error fetching most searched from network (background): \$e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLaboratories() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('laboratories');
    } catch (e) {
      log('Error leyendo cache laboratories: \$e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('laboratories')
            .select('laboratories_id, name, image_url, locations (name, block)')
            .limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save('laboratories', parsed);
        return parsed;
      } catch (e) {
        log('Error fetching laboratories from network: \$e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheLaboratories());
      return cached;
    }
  }

  Future<void> _fetchAndCacheLaboratories() async {
    try {
      final response = await supabase
          .from('laboratories')
          .select('laboratories_id, name, image_url, locations (name, block)')
          .limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('laboratories', parsed);
    } catch (e) {
      log('Error fetching laboratories from network (background): \$e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAccess() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('accesses');
    } catch (e) {
      log('Error leyendo cache accesses: \$e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('access')
            .select('access_id, name, image_url, locations (name, block)')
            .limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save('accesses', parsed);
        return parsed;
      } catch (e) {
        log('Error fetching accesses from network: \$e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheAccess());
      return cached;
    }
  }

  Future<void> _fetchAndCacheAccess() async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, image_url, locations (name, block)')
          .limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('accesses', parsed);
    } catch (e) {
      log('Error fetching accesses from network (background): \$e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchEverythingInBackground(
      dynamic _) async {
    final repo = HomeRepository();
    return await repo.fetchAllData();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('events');
    } catch (e) {
      log('Error leyendo cache events: \$e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('events')
            .select(
                'event_id, name, image_url, locations (name, block)')
            .limit(10);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save('events', parsed);
        return parsed;
      } catch (e) {
        log('Error fetching events from network: \$e');
        return cached;
      }
    } else {
      // Return cache immediately and refresh in background
      unawaited(_fetchAndCacheEvents());
      return cached;
    }
  }

  Future<void> _fetchAndCacheEvents() async {
    try {
      final response = await supabase
          .from('events')
          .select(
              'event_id, name, image_url, locations (name, block)')
          .limit(10);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('events', parsed);
    } catch (e) {
      log('Error fetching events from network (background): \$e');
    }
  }

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
}

Future<Map<String, List<Map<String, dynamic>>>> fetchAllDataIsolate(
    dynamic _) async {
  return await HomeRepository().fetchAllData();
}

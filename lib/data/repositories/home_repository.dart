import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

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
      log('Error leyendo cache locations: $e');
    }
    unawaited(_fetchAndCacheLocations());
    return cached;
  }

  Future<void> _fetchAndCacheLocations() async {
    try {
      final response = await supabase
          .from('locations')
          .select('location_id, name, image_url, block');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('locations', parsed);
    } catch (e) {
      log('Error fetching locations from network: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMostSearchedLocations() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('mostSearchedLocations');
    } catch (e) {
      log('Error leyendo cache most searched: $e');
    }
    unawaited(_fetchAndCacheMostSearchedLocations());
    return cached;
  }

  Future<void> _fetchAndCacheMostSearchedLocations() async {
    try {
      final response = await supabase
          .from('most_popular_user_interactions')
          .select('event_id,location_id,title_or_name,image_url')
          .limit(8);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('mostSearchedLocations', parsed);
    } catch (e) {
      log('Error fetching most searched locations from network: $e');
    }
  }

  // 🚀 NUEVO: Fetch de laboratorios
  Future<List<Map<String, dynamic>>> fetchLaboratories() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('laboratories');
    } catch (e) {
      log('Error leyendo cache laboratories: $e');
    }
    unawaited(_fetchAndCacheLaboratories());
    return cached;
  }

  Future<void> _fetchAndCacheLaboratories() async {
    try {
      final response = await supabase.from('laboratories').select(
          'laboratories_id, name, location, image_url, description, locations (name, block)');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('laboratories', parsed);
    } catch (e) {
      log('Error fetching laboratories from network: $e');
    }
  }

  // ✅ Actualizado: ahora incluye los laboratorios
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllData() async {
    final results = await Future.wait([
      fetchLocations(),
      fetchMostSearchedLocations(),
      fetchLaboratories(), // Añadido
    ]);

    return {
      'locations': results[0],
      'mostSearched': results[1],
      'laboratories': results[2],
    };
  }
}

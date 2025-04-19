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

  // Modificación: solo seleccionamos location_id, name, y otros campos que necesites.
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch('locations');
    } catch (e) {
      log('Error leyendo cache locations: $e');
    }

    // Lanza fetch de red en background
    unawaited(_fetchAndCacheLocations());

    return cached;
  }

  Future<void> _fetchAndCacheLocations() async {
    try {
      final response = await supabase
          .from('locations')
          .select('location_id, name, image_url'); // Campos necesarios
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('locations', parsed);
    } catch (e) {
      log('Error fetching locations from network: $e');
    }
  }

  // Modificación: solo seleccionamos los campos necesarios de eventos y ubicaciones relacionadas.
  Future<List<Map<String, dynamic>>> fetchRecommendations() async {
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch('recommendations');
    } catch (e) {
      log('Error leyendo cache recommendations: $e');
    }

    unawaited(_fetchAndCacheRecommendations());

    return cached;
  }

  Future<void> _fetchAndCacheRecommendations() async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, image_url') // Solo los campos necesarios
          .gte('end_time', DateTime.now().toIso8601String());

      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('recommendations', parsed);
    } catch (e) {
      log('Error fetching recommendations from network: $e');
    }
  }

  // Modificación: solo seleccionamos los campos necesarios de la tabla de interacciones más buscadas.
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

  // Recuperación de todos los datos
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllData() async {
    final results = await Future.wait([
      fetchLocations(),
      fetchRecommendations(),
      fetchMostSearchedLocations(),
    ]);

    return {
      'locations': results[0],
      'recommendations': results[1],
      'mostSearched': results[2],
    };
  }
}

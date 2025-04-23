import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class SportsFacilityRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  SportsFacilityRepository();

  // Obtener todas las instalaciones deportivas
  Future<List<Map<String, dynamic>>> fetchFacilities() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('sports_facilities');
    } catch (e) {
      log('Error leyendo cache de sports_facilities: $e');
    }
    unawaited(_fetchAndCacheAllFacilities());
    return cached;
  }

  Future<void> _fetchAndCacheAllFacilities() async {
    try {
      final response = await supabase
          .from('sports_facilities')
          .select('facility_id, name, location_id');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('sports_facilities', parsed);
    } catch (e) {
      log('Error al obtener sports_facilities desde red: $e');
    }
  }

  // Por ID
  Future<List<Map<String, dynamic>>> fetchFacilityById(int id) async {
    final cacheKey = 'sports_facility_$id';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de sports_facility por ID ($id): $e');
    }
    unawaited(_fetchAndCacheFacilityById(id, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheFacilityById(int id, String cacheKey) async {
    try {
      final response = await supabase
          .from('sports_facilities')
          .select('facility_id, name, location_id')
          .eq('facility_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener sports_facility por ID desde red ($id): $e');
    }
  }

  // Por ubicación
  Future<List<Map<String, dynamic>>> fetchFacilitiesByLocation(int locationId) async {
    final cacheKey = 'sports_facilities_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache sports_facilities por ubicación ($locationId): $e');
    }
    unawaited(_fetchAndCacheFacilitiesByLocation(locationId, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheFacilitiesByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('sports_facilities')
          .select('facility_id, name, location_id')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error al obtener sports_facilities por ubicación desde red ($locationId): $e');
    }
  }
}

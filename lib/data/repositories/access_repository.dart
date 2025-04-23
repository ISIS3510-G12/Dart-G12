import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class AccessRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  AccessRepository();

  // Recuperar todos los accesos
  Future<List<Map<String, dynamic>>> fetchAccess() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('access');
    } catch (e) {
      log('Error leyendo cache de accesos: $e');
    }
    unawaited(_fetchAndCacheAllAccess());
    return cached;
  }

  // Actualización de la caché con los datos de accesos
  Future<void> _fetchAndCacheAllAccess() async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)'); // Se incluye el campo 'block' de 'locations'
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('access', parsed);
    } catch (e) {
      log('Error al obtener accesos desde red: $e');
    }
  }

  // Recuperar acceso por ID
  Future<List<Map<String, dynamic>>> fetchAccessById(int accessId) async {
    final cacheKey = 'access_$accessId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de acceso por ID ($accessId): $e');
    }
    unawaited(_fetchAndCacheAccessById(accessId, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheAccessById(int accessId, String cacheKey) async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)') // Se incluye el campo 'block' de 'locations'
          .eq('access_id', accessId)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener acceso por ID desde red ($accessId): $e');
    }
  }

  // Recuperar accesos por ubicación
  Future<List<Map<String, dynamic>>> fetchAccessByLocation(int locationId) async {
    final cacheKey = 'access_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de accesos por ubicación ($locationId): $e');
    }
    unawaited(_fetchAndCacheAccessByLocation(locationId));
    return cached;
  }

  Future<void> _fetchAndCacheAccessByLocation(int locationId) async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)') 
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('access_location_$locationId', parsed);
    } catch (e) {
      log('Error al obtener accesos por ubicación desde red: $e');
    }
  }
}


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
    const cacheKey = 'access';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de accesos: $e');
    }

    if (cached.isEmpty) {
      // Si no hay cache, esperamos la llamada remota
      try {
        final response = await supabase
            .from('access')
            .select('access_id, name, location_id, image_url, locations(name, block)');
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener accesos desde red: $e');
        return cached;
      }
    } else {
      // Si hay cache, devolvemos ya y refrescamos en background
      unawaited(_fetchAndCacheAllAccess(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAllAccess(String cacheKey) async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching accesos from network (background): $e');
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

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('access')
            .select('access_id, name, location_id, image_url, locations(name, block)')
            .eq('access_id', accessId)
            .maybeSingle();
        if (response != null) {
          final list = [response];
          await _cache.save(cacheKey, list);
          return list;
        }
      } catch (e) {
        log('Error al obtener acceso por ID desde red ($accessId): $e');
      }
      return cached;
    } else {
      unawaited(_fetchAndCacheAccessById(accessId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAccessById(int accessId, String cacheKey) async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)')
          .eq('access_id', accessId)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error fetching acceso by ID from network (background) ($accessId): $e');
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

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('access')
            .select('access_id, name, location_id, image_url, locations(name, block)')
            .eq('location_id', locationId);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener accesos por ubicación desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheAccessByLocation(locationId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAccessByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('access')
          .select('access_id, name, location_id, image_url, locations(name, block)')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching accesos por ubicación from network (background) ($locationId): $e');
    }
  }
}

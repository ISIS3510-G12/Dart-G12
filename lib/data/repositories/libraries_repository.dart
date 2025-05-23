import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class LibraryRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  LibraryRepository();

  // Obtener todas las bibliotecas
  Future<List<Map<String, dynamic>>> fetchLibraries() async {
    const cacheKey = 'libraries';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de libraries: $e');
    }

    if (cached.isEmpty) {
      try {
        await _fetchAndCacheAllLibraries(cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener libraries desde red: $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheAllLibraries(cacheKey));
      return cached;
    }
  }

  // Obtener y guardar en caché todas las bibliotecas
  Future<void> _fetchAndCacheAllLibraries(String cacheKey) async {
    try {
      final response = await supabase
          .from('libraries')
          .select('library_id, name, image_url, location_id, locations(name, block)');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error al obtener libraries desde red (background): $e');
    }
  }

  // Obtener biblioteca por ID
  Future<List<Map<String, dynamic>>> fetchLibraryById(int id) async {
    final cacheKey = 'library_$id';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
      if (cached.isNotEmpty) {
        unawaited(_fetchAndCacheLibraryById(id, cacheKey));
        return cached;
      }
    } catch (e) {
      log('Error leyendo cache de library por ID ($id): $e');
    }

    try {
      await _fetchAndCacheLibraryById(id, cacheKey);
      return await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error al obtener library por ID desde red ($id): $e');
      return [];
    }
  }

  Future<void> _fetchAndCacheLibraryById(int id, String cacheKey) async {
    try {
      final response = await supabase
          .from('libraries')
          .select('library_id, name, image_url, location_id, locations (name, block)')
          .eq('library_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener library por ID desde red (background) ($id): $e');
    }
  }

  // Obtener bibliotecas por ubicación
  Future<List<Map<String, dynamic>>> fetchLibrariesByLocation(int locationId) async {
    final cacheKey = 'libraries_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache libraries por ubicación ($locationId): $e');
    }

    if (cached.isEmpty) {
      try {
        await _fetchAndCacheLibrariesByLocation(locationId, cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener libraries por ubicación desde red: $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheLibrariesByLocation(locationId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheLibrariesByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('libraries')
          .select('library_id, name, image_url, location_id, locations (name, block)')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error al obtener libraries por ubicación desde red (background) ($locationId): $e');
    }
  }
}

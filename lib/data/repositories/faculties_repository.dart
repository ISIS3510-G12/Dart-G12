import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class FacultyRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  FacultyRepository();

  // Obtener todas las facultades (cache + background refresh)
  Future<List<Map<String, dynamic>>> fetchFaculties() async {
    const cacheKey = 'faculties';
    List<Map<String, dynamic>> cached = [];

    // 1. Leer de cache si existe
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de facultades: $e');
    }

    if (cached.isEmpty) {
      // No hay cache: bloquea hasta obtener de red y cachear
      try {
        await _fetchAndCacheAllFaculties(cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener facultades desde red: $e');
        return [];
      }
    } else {
      // Hay cache: devuelve inmediatamente y refresca en background
      unawaited(_fetchAndCacheAllFaculties(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAllFaculties(String cacheKey) async {
    try {
      final response = await supabase
          .from('faculties')
          .select('faculty_id, name, image_url');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
      log('Facultades guardadas en cache (count: ${parsed.length})');
    } catch (e) {
      log('Error al refrescar facultades en background: $e');
    }
  }

  // Obtener una facultad por ID (cache + background refresh)
  Future<List<Map<String, dynamic>>> fetchFacultyById(int facultyId) async {
    final cacheKey = 'faculty_$facultyId';
    List<Map<String, dynamic>> cached = [];

    // 1. Leer de cache si existe
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de facultad por ID ($facultyId): $e');
    }

    if (cached.isEmpty) {
      // No hay cache: bloquea hasta obtener de red y cachear
      try {
        await _fetchAndCacheFacultyById(facultyId, cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener faculty por ID desde red ($facultyId): $e');
        return [];
      }
    } else {
      // Hay cache: devuelve inmediatamente y refresca en background
      unawaited(_fetchAndCacheFacultyById(facultyId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheFacultyById(int facultyId, String cacheKey) async {
    try {
      final response = await supabase
          .from('faculties')
          .select('faculty_id, name, image_url, departments(department_id, name, image_url)')
          .eq('faculty_id', facultyId)
          .maybeSingle();

      if (response != null) {
        final Map<String, dynamic> respMap = Map<String, dynamic>.from(response);
        final renamedResponse = {
          ...respMap,
          'programs': respMap['departments'],
        }..remove('departments');

        await _cache.save(cacheKey, [renamedResponse]);
      }
    } catch (e) {
      log('Error al obtener facultad por ID desde red (background) ($facultyId): $e');
    }
  }
}

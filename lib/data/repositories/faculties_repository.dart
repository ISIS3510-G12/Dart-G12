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

  // Obtener todas las facultades
  Future<List<Map<String, dynamic>>> fetchFaculties() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('faculties');
    } catch (e) {
      log('Error leyendo cache de facultades: $e');
    }
    unawaited(_fetchAndCacheAllFaculties());
    return cached;
  }

  // Obtener y guardar en caché todas las facultades
  Future<void> _fetchAndCacheAllFaculties() async {
    try {
      final response = await supabase
          .from('faculties')
          .select('faculty_id, name');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('faculties', parsed);
    } catch (e) {
      log('Error al obtener facultades desde red: $e');
    }
  }

  // Obtener una facultad por ID
  Future<List<Map<String, dynamic>>> fetchFacultyById(int facultyId) async {
    final cacheKey = 'faculty_$facultyId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de facultad por ID ($facultyId): $e');
    }
    unawaited(_fetchAndCacheFacultyById(facultyId, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheFacultyById(int facultyId, String cacheKey) async {
    try {
      final response = await supabase
          .from('faculties')
          .select('faculty_id, name')
          .eq('faculty_id', facultyId)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener facultad por ID desde red ($facultyId): $e');
    }
  }
}

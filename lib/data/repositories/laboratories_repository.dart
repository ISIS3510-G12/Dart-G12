import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class LaboratoriesRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  LaboratoriesRepository();

  // Recuperar todos los laboratorios con su "block" asociado
  Future<List<Map<String, dynamic>>> fetchLaboratories() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('laboratories');
    } catch (e) {
      log('Error leyendo cache de laboratorios: $e');
    }
    unawaited(_fetchAndCacheAllLaboratories());
    return cached;
  }

  // Actualización de la caché con los datos de laboratorios, incluyendo el "block"
  Future<void> _fetchAndCacheAllLaboratories() async {
    try {
      final response = await supabase.from('laboratories').select('''
        laboratories_id,
        name,
        image_url,
        locations (name, block)  
      ''');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('laboratories', parsed);
    } catch (e) {
      log('Error al obtener laboratorios desde red: $e');
    }
  }

  /// Obtener un laboratorio por su ID
  Future<Map<String, dynamic>?> fetchLaboratoryById(int id) async {
    final cacheKey = 'laboratory_$id';

    try {
      final cached = await _cache.fetch(cacheKey);
      if (cached.isNotEmpty) return cached.first;
    } catch (e) {
      log('Error leyendo cache de laboratorio por ID ($id): $e');
    }

    try {
      final response = await supabase.from('laboratories').select('''
          laboratories_id, name, location, image_url, description,
          department_id, location_id,
          locations (name)
        ''').eq('laboratories_id', id).maybeSingle();

      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }

      return response;
    } catch (e) {
      log('Error al obtener laboratorio por ID desde red ($id): $e');
      return null;
    }
  }

  // Recuperar laboratorios por ubicación
  Future<List<Map<String, dynamic>>> fetchLaboratoriesByLocation(
      int locationId) async {
    final cacheKey = 'laboratories_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de laboratorios por ubicación ($locationId): $e');
    }
    unawaited(_fetchAndCacheLaboratoriesByLocation(locationId));
    return cached;
  }

  Future<void> _fetchAndCacheLaboratoriesByLocation(int locationId) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select(
              'laboratories_id, name, location, image_url, description, department_id, location_id, locations (name, block)') // Incluye el bloque
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('laboratories_location_$locationId', parsed);
    } catch (e) {
      log('Error al obtener laboratorios por ubicación desde red: $e');
    }
  }

  // Recuperación de laboratorios por departamento
  Future<List<Map<String, dynamic>>> fetchLaboratoriesByDepartment(
      int departmentId) async {
    final cacheKey = 'laboratories_department_$departmentId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de laboratorios por departamento ($departmentId): $e');
    }
    unawaited(_fetchAndCacheLaboratoriesByDepartment(departmentId));
    return cached;
  }

  Future<void> _fetchAndCacheLaboratoriesByDepartment(int departmentId) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select(
              'laboratories_id, name, location, image_url, description, department_id, location_id, locations (block)') // Incluye el bloque
          .eq('department_id', departmentId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('laboratories_department_$departmentId', parsed);
    } catch (e) {
      log('Error al obtener laboratorios por departamento desde red: $e');
    }
  }
}

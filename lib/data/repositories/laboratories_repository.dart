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
    const cacheKey = 'laboratories';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de laboratorios: $e');
    }

    if (cached.isEmpty) {
      try {
        await _fetchAndCacheAllLaboratories(cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener laboratorios desde red: $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheAllLaboratories(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAllLaboratories(String cacheKey) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select('laboratories_id, name, image_url, locations(name, block)');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching laboratorios from network (background): $e');
    }
  }

  // Obtener un laboratorio por su ID
  Future<Map<String, dynamic>?> fetchLaboratoryById(int id) async {
    final cacheKey = 'laboratory_$id';
    try {
      final cached = await _cache.fetch(cacheKey);
      if (cached.isNotEmpty) {
        unawaited(_fetchAndCacheLaboratoryById(id, cacheKey));
        return cached.first;
      }
    } catch (e) {
      log('Error leyendo cache de laboratorio por ID ($id): $e');
    }

    try {
      await _fetchAndCacheLaboratoryById(id, cacheKey);
      final cached = await _cache.fetch(cacheKey);
      return cached.isNotEmpty ? cached.first : null;
    } catch (e) {
      log('Error al obtener laboratorio por ID desde red ($id): $e');
      return null;
    }
  }

  Future<void> _fetchAndCacheLaboratoryById(int id, String cacheKey) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select('laboratories_id, name, location, image_url, description, department_id, location_id, locations(name, block)')
          .eq('laboratories_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error fetching laboratorio by ID from network (background) ($id): $e');
    }
  }

  // Recuperar laboratorios por ubicación
  Future<List<Map<String, dynamic>>> fetchLaboratoriesByLocation(int locationId) async {
    final cacheKey = 'laboratories_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de laboratorios por ubicación ($locationId): $e');
    }

    if (cached.isEmpty) {
      try {
        await _fetchAndCacheLaboratoriesByLocation(locationId, cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener laboratorios por ubicación desde red: $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheLaboratoriesByLocation(locationId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheLaboratoriesByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select('laboratories_id, name, location, image_url, description, department_id, location_id, locations(name, block)')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching laboratorios por ubicación from network (background) ($locationId): $e');
    }
  }

  // Recuperar laboratorios por departamento
  Future<List<Map<String, dynamic>>> fetchLaboratoriesByDepartment(int departmentId) async {
    final cacheKey = 'laboratories_department_$departmentId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de laboratorios por departamento ($departmentId): $e');
    }

    if (cached.isEmpty) {
      try {
        await _fetchAndCacheLaboratoriesByDepartment(departmentId, cacheKey);
        return await _cache.fetch(cacheKey);
      } catch (e) {
        log('Error al obtener laboratorios por departamento desde red: $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheLaboratoriesByDepartment(departmentId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheLaboratoriesByDepartment(int departmentId, String cacheKey) async {
    try {
      final response = await supabase
          .from('laboratories')
          .select('laboratories_id, name, location, image_url, description, department_id, location_id, locations(name, block)')
          .eq('department_id', departmentId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching laboratorios por departamento from network (background) ($departmentId): $e');
    }
  }
}

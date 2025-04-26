import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class DepartmentsRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  DepartmentsRepository();

  // Recuperar todos los departamentos
  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('departments');
    } catch (e) {
      log('Error leyendo cache de departamentos: $e');
    }
    unawaited(_fetchAndCacheAllDepartments());
    return cached;
  }

  // Actualización de la caché con los datos de departamentos
  Future<void> _fetchAndCacheAllDepartments() async {
    try {
      final response = await supabase
          .from('departments')
          .select('department_id, name, faculty_id, image_url');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('departments', parsed);
    } catch (e) {
      log('Error al obtener departamentos desde red: $e');
    }
  }

  // Recuperar departamentos por ID
  Future<List<Map<String, dynamic>>> fetchDepartmentById(int departmentId) async {
    final cacheKey = 'department_$departmentId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de departamento por ID ($departmentId): $e');
    }
    unawaited(_fetchAndCacheDepartmentById(departmentId, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheDepartmentById(int departmentId, String cacheKey) async {
    try {
      final response = await supabase
          .from('departments')
          .select('department_id, name, faculty_id, image_url')
          .eq('department_id', departmentId)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener departamento por ID desde red ($departmentId): $e');
    }
  }

  // Recuperar departamentos por facultad
  Future<List<Map<String, dynamic>>> fetchDepartmentsByFaculty(int facultyId) async {
    final cacheKey = 'departments_faculty_$facultyId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de departamentos por facultad ($facultyId): $e');
    }
    unawaited(_fetchAndCacheDepartmentsByFaculty(facultyId));
    return cached;
  }

  Future<void> _fetchAndCacheDepartmentsByFaculty(int facultyId) async {
    try {
      final response = await supabase
          .from('departments')
          .select('department_id, name, faculty_id, image_url')
          .eq('faculty_id', facultyId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('departments_faculty_$facultyId', parsed);
    } catch (e) {
      log('Error al obtener departamentos por facultad desde red: $e');
    }
  }

  // Recuperar departamentos por ubicación
  Future<List<Map<String, dynamic>>> fetchDepartmentsByLocation(int locationId) async {
    final cacheKey = 'departments_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de departamentos por ubicación ($locationId): $e');
    }
    unawaited(_fetchAndCacheDepartmentsByLocation(locationId));
    return cached;
  }

  Future<void> _fetchAndCacheDepartmentsByLocation(int locationId) async {
    try {
      final response = await supabase
          .from('department_locations')
          .select('department_id')
          .eq('location_id', locationId);

      final departmentIds = (response as List<dynamic>)
          .map((e) => e['department_id'] as int)
          .toList();

      final departmentsResponse = await supabase
          .from('departments')
          .select('department_id, name, faculty_id, image_url')
          .eq('department_id', departmentIds);

      final parsed = await compute(_parseList, departmentsResponse as List<dynamic>);
      await _cache.save('departments_location_$locationId', parsed);
    } catch (e) {
      log('Error al obtener departamentos por ubicación desde red: $e');
    }
  }
}

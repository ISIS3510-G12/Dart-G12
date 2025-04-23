import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class AuditoriumRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  AuditoriumRepository();

  // Obtener todos los auditorios
  Future<List<Map<String, dynamic>>> fetchAuditoriums() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('auditoriums');
    } catch (e) {
      log('Error leyendo cache de auditoriums: $e');
    }
    unawaited(_fetchAndCacheAllAuditoriums());
    return cached;
  }

  // Obtener y guardar en caché todos los auditorios
  Future<void> _fetchAndCacheAllAuditoriums() async {
    try {
      final response = await supabase
          .from('auditoriums')
          .select('auditorium_id, name, location_id');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('auditoriums', parsed);
    } catch (e) {
      log('Error al obtener auditoriums desde red: $e');
    }
  }

  // Obtener un auditorio por ID
  Future<List<Map<String, dynamic>>> fetchAuditoriumById(int id) async {
    final cacheKey = 'auditorium_$id';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de auditorium por ID ($id): $e');
    }
    unawaited(_fetchAndCacheAuditoriumById(id, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheAuditoriumById(int id, String cacheKey) async {
    try {
      final response = await supabase
          .from('auditoriums')
          .select('auditorium_id, name, location_id')
          .eq('auditorium_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error al obtener auditorium por ID desde red ($id): $e');
    }
  }

  // Obtener auditorios por ubicación
  Future<List<Map<String, dynamic>>> fetchAuditoriumsByLocation(int locationId) async {
    final cacheKey = 'auditoriums_location_$locationId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache auditoriums por ubicación ($locationId): $e');
    }
    unawaited(_fetchAndCacheAuditoriumsByLocation(locationId, cacheKey));
    return cached;
  }

  Future<void> _fetchAndCacheAuditoriumsByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('auditoriums')
          .select('auditorium_id, name, location_id')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error al obtener auditoriums por ubicación desde red ($locationId): $e');
    }
  }
}

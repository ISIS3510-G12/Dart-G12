import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class EventRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  EventRepository();

  /// Obtener todos los eventos con caché
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch('events');
    } catch (e) {
      log('Error leyendo cache de eventos: $e');
    }

    unawaited(_fetchAndCacheAllEvents());

    return cached;
  }

  Future<void> _fetchAndCacheAllEvents() async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type');

      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('events', parsed);
    } catch (e) {
      log('Error al obtener eventos desde red: $e');
    }
  }

  /// Obtener eventos por tipo con caché individual
  Future<List<Map<String, dynamic>>> fetchEventsByType(String type) async {
    final cacheKey = 'events_type_$type';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache eventos por tipo ($type): $e');
    }

    unawaited(_fetchAndCacheEventsByType(type));

    return cached;
  }

  Future<void> _fetchAndCacheEventsByType(String type) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type')
          .eq('type', type);

      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('events_type_$type', parsed);
    } catch (e) {
      log('Error al obtener eventos por tipo desde red: $e');
    }
  }

  /// Obtener un evento por ID (sin caché, normalmente esto es detalle puntual)
  Future<Map<String, dynamic>?> fetchEventById(int id) async {
    final response = await supabase
        .from('events')
        .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .eq('event_id', id)
        .maybeSingle();

    return response;
  }

  /// Obtener eventos con paginación (sin caché, ya que es dinámico)
  Future<List<Map<String, dynamic>>> fetchEventsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('events')
        .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .range(start, end);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener eventos por ubicación con caché por ubicación
  Future<List<Map<String, dynamic>>> fetchEventsByLocation(int locationId) async {
    final cacheKey = 'events_location_$locationId';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache eventos por ubicación ($locationId): $e');
    }

    unawaited(_fetchAndCacheEventsByLocation(locationId));

    return cached;
  }

  Future<void> _fetchAndCacheEventsByLocation(int locationId) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type')
          .eq('location_id', locationId);

      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('events_location_$locationId', parsed);
    } catch (e) {
      log('Error al obtener eventos por ubicación desde red: $e');
    }
  }
}

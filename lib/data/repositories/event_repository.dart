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

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    const cacheKey = 'events';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de eventos: $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('events')
            .select('event_id, name, description, image_url, location_id, start_time, end_time, created_at, locations (name, block)');
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener eventos desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheAllEvents(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAllEvents(String cacheKey) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, name, description, image_url, location_id, start_time, end_time, created_at, locations (name, block)');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching eventos from network (background): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventsByType(String type) async {
    final cacheKey = 'events_type_$type';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache eventos por tipo ($type): $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('events')
            .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type, locations (name, block), departments(name)')
            .eq('type', type);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener eventos por tipo desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheEventsByType(type, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheEventsByType(String type, String cacheKey) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type, locations (name, block), departments(name)')
          .eq('type', type);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching eventos por tipo from network (background) ($type): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventById(int id) async {
    final cacheKey = 'event_$id';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
      if (cached.isNotEmpty) {
        unawaited(_fetchAndCacheEventById(id, cacheKey));
        return cached;
      }
    } catch (e) {
      log('Error leyendo cache de evento por ID ($id): $e');
    }

    try {
      final response = await supabase
          .from('events')
          .select('event_id, name, description, image_url, location_id, start_time, end_time, created_at, locations (name, block), departments(name)')
          .eq('event_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
      return response != null ? [response] : [];
    } catch (e) {
      log('Error al obtener evento por ID desde red ($id): $e');
      return cached;
    }
  }

  Future<void> _fetchAndCacheEventById(int id, String cacheKey) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, name, description, image_url, location_id, start_time, end_time, created_at, locations (name, block), departments(name)')
          .eq('event_id', id)
          .maybeSingle();
      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error fetching evento by ID from network (background) ($id): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventsByLocation(int locationId) async {
    final cacheKey = 'events_location_$locationId';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache eventos por ubicación ($locationId): $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('events')
            .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type, locations (name, block), departments(name)')
            .eq('location_id', locationId);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener eventos por ubicación desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheEventsByLocation(locationId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheEventsByLocation(int locationId, String cacheKey) async {
    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type, locations (name, block), departments(name)')
          .eq('location_id', locationId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching eventos por ubicación from network (background) ($locationId): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    try {
      final response = await supabase
          .from('events')
          .select('event_id, title, description, image_url, location_id, start_time, end_time, created_at, type, locations (name, block), departments(name)')
          .range(start, end);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error al obtener eventos paginados: $e');
      return [];
    }
  }
}

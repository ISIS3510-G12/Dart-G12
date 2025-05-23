import 'dart:developer';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class ServicesRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  ServicesRepository();

  Future<List<Map<String, dynamic>>> fetchServices() async {
    const cacheKey = 'services';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de servicios: $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('services')
            .select('service_id, name, service_type_id,image_url');
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener servicios desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheAllServices(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheAllServices(String cacheKey) async {
    try {
      final response = await supabase
          .from('services')
          .select('service_id, name, service_type_id, image_url');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching servicios desde red (background): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServiceTypes() async {
    const cacheKey = 'serviceTypes';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de tipos de servicio: $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('service_types')
            .select('service_type_id, name');
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener tipos de servicio desde red: $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheServiceTypes(cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheServiceTypes(String cacheKey) async {
    try {
      final response = await supabase
          .from('service_types')
          .select('service_type_id, name');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching tipos de servicio desde red (background): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServicesByType(int typeId) async {
    final cacheKey = 'services_type_$typeId';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de servicios por tipo ($typeId): $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('services')
            .select('service_id, name, service_type_id')
            .eq('service_type_id', typeId);
        final parsed = await compute(_parseList, response as List<dynamic>);
        await _cache.save(cacheKey, parsed);
        return parsed;
      } catch (e) {
        log('Error al obtener servicios por tipo desde red ($typeId): $e');
        return cached;
      }
    } else {
      unawaited(_fetchAndCacheServicesByType(typeId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheServicesByType(int typeId, String cacheKey) async {
    try {
      final response = await supabase
          .from('services')
          .select('service_id, name, service_type_id')
          .eq('service_type_id', typeId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error fetching servicios por tipo desde red (background) ($typeId): $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServiceDetail(int serviceId) async {
    final cacheKey = 'service_detail_$serviceId';
    List<Map<String, dynamic>> cached = [];

    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache del detalle del servicio ($serviceId): $e');
    }

    if (cached.isEmpty) {
      try {
        final response = await supabase
            .from('services')
            .select('service_id, name, service_type_id, service_types(name)')
            .eq('service_id', serviceId)
            .maybeSingle();

        if (response != null) {
          await _cache.save(cacheKey, [response]);
          return [response];
        }

        return [];
      } catch (e) {
        log('Error al obtener detalle del servicio desde red ($serviceId): $e');
        return [];
      }
    } else {
      unawaited(_fetchAndCacheServiceDetail(serviceId, cacheKey));
      return cached;
    }
  }

  Future<void> _fetchAndCacheServiceDetail(int serviceId, String cacheKey) async {
    try {
      final response = await supabase
          .from('services')
          .select('service_id, name, service_type_id, image_url, service_types(name)')
          .eq('service_id', serviceId)
          .maybeSingle();

      if (response != null) {
        await _cache.save(cacheKey, [response]);
      }
    } catch (e) {
      log('Error actualizando detalle del servicio en background ($serviceId): $e');
    }
  }

}



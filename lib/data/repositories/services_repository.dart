import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:async';

List<Map<String, dynamic>> _parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class ServicesRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService _cache = LocalStorageService();

  ServicesRepository();

  // Recupera servicios desde el caché y actualiza en segundo plano
  Future<List<Map<String, dynamic>>> fetchServices() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('services');
    } catch (e) {
      log('Error leyendo cache de servicios: $e');
    }
    // Se actualiza desde red sin bloquear la interfaz
    unawaited(_fetchAndCacheAllServices());
    return cached;
  }

  // Descarga todos los servicios desde Supabase y los guarda en caché
  Future<void> _fetchAndCacheAllServices() async {
    try {
      final response = await supabase
          .from('services')
          .select('service_id, name, service_type_id');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('services', parsed);
    } catch (e) {
      log('Error al obtener servicios desde red: $e');
    }
  }

  // Recupera tipos de servicio desde caché y actualiza en segundo plano
  Future<List<Map<String, dynamic>>> fetchServiceTypes() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch('serviceTypes');
    } catch (e) {
      log('Error leyendo cache de tipos de servicio: $e');
    }
    unawaited(_fetchAndCacheServiceTypes());
    return cached;
  }

  // Descarga los tipos de servicio y guarda en caché
  Future<void> _fetchAndCacheServiceTypes() async {
    try {
      final response = await supabase
          .from('service_types')
          .select('service_type_id, name');
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save('serviceTypes', parsed);
    } catch (e) {
      log('Error al obtener tipos de servicio desde red: $e');
    }
  }

  // Recupera ubicaciones específicas de un servicio por su ID (con detalle), y actualiza en segundo plano
  Future<List<Map<String, dynamic>>> fetchServiceLocations(int serviceId) async {
    final cacheKey = 'service_locations_$serviceId';
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await _cache.fetch(cacheKey);
    } catch (e) {
      log('Error leyendo cache de ubicaciones de servicio ($serviceId): $e');
    }
    unawaited(_fetchAndCacheServiceLocations(serviceId, cacheKey));
    return cached;
  }

  // Descarga las ubicaciones de un servicio y guarda en caché
  Future<void> _fetchAndCacheServiceLocations(int serviceId, String cacheKey) async {
    try {
      final response = await supabase
          .from('service_locations')
          .select('service_id, location_id, location_detail')
          .eq('service_id', serviceId);
      final parsed = await compute(_parseList, response as List<dynamic>);
      await _cache.save(cacheKey, parsed);
    } catch (e) {
      log('Error al obtener ubicaciones de servicio desde red ($serviceId): $e');
    }
  }

  // Carga todos los datos disponibles: servicios y tipos de servicio
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllData() async {
    final results = await Future.wait([
      fetchServices(),
      fetchServiceTypes(),
    ]);

    return {
      'services': results[0],
      'serviceTypes': results[1],
    };
  }
}

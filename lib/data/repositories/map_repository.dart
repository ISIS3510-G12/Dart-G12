import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/services/local_storage_service.dart';
import 'dart:developer';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:developer';


List<Map<String, dynamic>> parseList(List<dynamic> response) {
  return List<Map<String, dynamic>>.from(response);
}

class MapRepository {
  final supabase = SupabaseService().client;
  final LocalStorageService cache = LocalStorageService();

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    List<Map<String, dynamic>> cached = [];
    try {
      cached = await cache.fetch('locationsmap');
    } catch (e) {
      log('Error leyendo cache locations: $e');
    }
    log('Cached locations: $cached');
    unawaited(_fetchAndCacheLocations());
    return cached;
  }

  Future<void> _fetchAndCacheLocations() async {
    try {
      final response = await supabase.from('locations').select('location_id, block, latitude, longitude');
      final parsed = await compute(parseList, response as List<dynamic>);
      await cache.save('locationsmap', parsed);
    } catch (e) {
      log('Error fetching locations from network: $e');
    }
  }

  /// Obtiene la ruta desde la tabla 'routes' según los id de inicio y fin de manera concurrente
  Future<Map<String, dynamic>?> fetchRouteData(int fromId, int toId) async {
    final routeResponse = await supabase
        .from('routes')
        .select('id, start_location_id, end_location_id')
        .eq('start_location_id', fromId)
        .eq('end_location_id', toId)
        .maybeSingle();
    return routeResponse;
  }

  /// Obtiene la información de una ubicación en la tabla 'locations' por su id
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final response = await supabase
        .from('locations')
        .select('name, latitude, longitude')
        .eq('location_id', id)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchRouteNodes(int routeId) async {
    final nodesResponse = await supabase
        .from('route_nodes')
        .select('latitude, longitude, node_name, node_index')
        .eq('route_id', routeId)
        .order('node_index', ascending: true);
    return List<Map<String, dynamic>>.from(nodesResponse);
  }
Future<Map<String, dynamic>?> fetchShortestPath(int startId, int endId) async {
  try {
    // 1) Llamo al RPC
    final raw = await supabase.rpc('get_shortest_path', params: {
      'start_id': startId,
      'end_id': endId,
    });

    // 2) Lo trato como lista
    final rows = raw as List<dynamic>?;

    // 3) Si es nulo o vacío, no hay ruta
    if (rows == null || rows.isEmpty) {
      log('fetchShortestPath: no rows returned');
      return null;
    }

    // 4) Desempaqueto el primer row como Map
    final row = rows[0] as Map<String, dynamic>;

    // 5) Extraigo y convierto
    final totalCost = row['total_cost'] as double;
    final path = (row['path'] as List<dynamic>)
        .map((e) => int.parse(e.toString()))
        .toList();

    log('fetchShortestPath ⇒ totalCost: $totalCost  path: $path');

    return {
      'total_cost': totalCost,
      'path': path,
    };
  } catch (e) {
    log('Error al obtener ruta más corta: $e');
    return null;
  }
}

/// En map_repository.dart
Future<List<Map<String, dynamic>>> fetchNodesByIds(List<int> nodeIds) async {
  List<Map<String, dynamic>> nodes = [];

  try {
    for (int nodeId in nodeIds) {
      final response = await supabase
          .from('nodes')
          .select('id, location_id, name, lat, lng')
          .eq('id', nodeId); // Buscar por cada nodo ID

      if (response != null && response.isNotEmpty) {
        // Si la respuesta contiene datos, los agregamos a la lista
        nodes.add(Map<String, dynamic>.from(response[0] as Map));
      }
    }
  } catch (e) {
    log("Error al obtener los nodos: $e");
  }

  return nodes;
}





  Future<Map<String, dynamic>> fetchCompleteRouteData(int fromId, int toId, int routeId) async {
    final results = await Future.wait([
      fetchLocationById(fromId),
      fetchLocationById(toId),
      fetchRouteData(fromId, toId),
      fetchRouteNodes(routeId)
    ]);
    return {
      'from_location': results[0],
      'to_location': results[1],
      'route_data': results[2],
      'route_nodes': results[3],
    };
  }

  
}

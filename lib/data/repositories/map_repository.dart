import 'package:dart_g12/data/services/supabase_service.dart';

class MapRepository {
  final supabase = SupabaseService().client;

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    final response = await supabase.from('locations').select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtiene la ruta desde la tabla 'routes' según los id de inicio y fin
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
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Obtiene los nodos intermedios de la tabla 'route_nodes' para una ruta dada
  Future<List<Map<String, dynamic>>> fetchRouteNodes(int routeId) async {
    final nodesResponse = await supabase
        .from('route_nodes')
        .select('latitude, longitude, node_name, node_index')
        .eq('route_id', routeId)
        .order('node_index', ascending: true);
    return List<Map<String, dynamic>>.from(nodesResponse);
  }
}

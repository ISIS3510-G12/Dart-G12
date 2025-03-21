import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  HomeRepository();

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final response = await supabase.from('locations').select();

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching locations: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecommendations() async {
    try {
      final response = await supabase
          .from('recommendations')
          .select('*, locations(name)') // Incluye el nombre del lugar
          .gte('end_time',
              DateTime.now().toIso8601String()); // Solo eventos futuros

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching recommendations: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchMostSearchedLocation() async {
    try {
      final response = await supabase
          .from('user_actions')
          .select(
              'location_id, count:count(*)') // Contar búsquedas por location_id
          .eq('action_type', 'search') // Filtrar solo búsquedas
          .order('count', ascending: false) // Ordenar por más buscados
          .limit(1)
          .maybeSingle(); // Obtener un solo resultado o null

      if (response == null || response['location_id'] == null) {
        return null;
      }

      // Ahora obtenemos los datos del lugar más buscado
      final locationResponse = await supabase
          .from('locations')
          .select()
          .eq('id', response['location_id'])
          .maybeSingle(); // Obtener datos del lugar

      return locationResponse;
    } catch (error) {
      print('Error fetching most searched location: $error');
      return null;
    }
  }
}

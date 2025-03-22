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
    final response = await Supabase.instance.client
        .from('pl_locations_view')
        .select('*')
        .limit(1)
        .single();

    return response;
  }
}

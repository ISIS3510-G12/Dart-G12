import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  final supabase = SupabaseService().client;

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
          .from('events')
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

  Future<List<Map<String, dynamic>>> fetchMostSearchedLocations() async {
    try {
      final response = await Supabase.instance.client
          .from('most_popular_user_interactions')
          .select('*')
          .limit(8); 

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching most searched locations: $error');
      return [];
    }
  }
}

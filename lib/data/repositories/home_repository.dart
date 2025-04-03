import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class HomeRepository {
  final supabase = SupabaseService().client;

  HomeRepository();

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final List<dynamic> response = await supabase.from('locations').select().limit(10);
      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (error) {
      log('Error fetching locations: $error');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> fetchRecommendations() async {
    try {
      final List<dynamic> response = await supabase
          .from('events')
          .select('*, locations(name)') 
          .gte('end_time', DateTime.now().toIso8601String()) 
          .order('end_time', ascending: true)
          .limit(10); 

      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (error) {
      log('Error fetching recommendations: $error');
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

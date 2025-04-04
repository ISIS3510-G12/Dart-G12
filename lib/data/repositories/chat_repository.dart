import 'dart:developer';
import 'package:dart_g12/data/services/supabase_service.dart    ';

class ChatRepository {
  final supabase = SupabaseService().client;

  ChatRepository();

  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final List<dynamic> response = await supabase.from('locations').select();
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
          .order('end_time', ascending: true); 

      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (error) {
      log('Error fetching recommendations: $error');
      return [];
    }
  }
}
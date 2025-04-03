import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';

class EventRepository {
  final supabase = SupabaseService().client;

  EventRepository();

  /// 🔹 Obtener todos los eventos futuros
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    // Obtener la ubicación actual del usuario
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    try {
      // Obtener eventos futuros desde Supabase (filtrando por `end_time`)
      final response = await supabase
          .from('events')
          .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
          .gte('end_time', DateTime.now().toIso8601String()); // Solo eventos futuros

      if (response.isEmpty) {
        throw Exception('No se encontraron eventos.');
      }

      List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(response);

      // Ordenar los eventos por proximidad al usuario
      events.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
            userLat, userLon, a['latitude'], a['longitude']);
        double distanceB = Geolocator.distanceBetween(
            userLat, userLon, b['latitude'], b['longitude']);
        return distanceA.compareTo(distanceB);
      });

      return events;

    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// 🔹 Obtener eventos futuros por tipo
  Future<List<Map<String, dynamic>>> fetchEventsByType(String type) async {
    try {
      final response = await supabase
          .from('events')
          .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
          .eq('type', type)
          .gte('end_time', DateTime.now().toIso8601String()); // Solo eventos futuros

      if (response.isEmpty) {
        throw Exception('No se encontraron eventos del tipo: $type.');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events by type: $e');
      return [];
    }
  }

  /// 🔹 Obtener un evento por su ID
  Future<Map<String, dynamic>?> fetchEventById(int id) async {
    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  /// 🔹 Obtener eventos con paginación, solo futuros
  Future<List<Map<String, dynamic>>> fetchEventsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .gte('end_time', DateTime.now().toIso8601String())
        .range(start, end)
        ; // Solo eventos futuros

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener eventos futuros de una ubicación específica
  Future<List<Map<String, dynamic>>> fetchEventsByLocation(int locationId) async {
    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .eq('location_id', locationId)
        .gte('end_time', DateTime.now().toIso8601String()); // Solo eventos futuros

    if (response.isEmpty) {
      throw Exception('No se encontraron eventos para esta ubicación.');
    }

    return List<Map<String, dynamic>>.from(response);
  }
}

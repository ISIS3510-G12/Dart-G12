import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';

class EventRepository {
  final supabase = SupabaseService().client;

  EventRepository();

  /// 🔹 Obtener todos los eventos y ordenarlos por proximidad al usuario
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    // Obtener la ubicación actual del usuario
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    // Obtener todos los eventos desde Supabase
    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type');

    if (response.isEmpty) {
      throw Exception('No se encontraron eventos.');
    }

    List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(response);

    return events;
  }

  /// 🔹 Obtener eventos por tipo
  Future<List<Map<String, dynamic>>> fetchEventsByType(String type) async {
    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .eq('type', type);

    if (response.isEmpty) {
      throw Exception('No se encontraron eventos del tipo: $type.');
    }

    return List<Map<String, dynamic>>.from(response);
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

  /// 🔹 Obtener eventos con paginación
  Future<List<Map<String, dynamic>>> fetchEventsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .range(start, end);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener eventos de una ubicación específica
  Future<List<Map<String, dynamic>>> fetchEventsByLocation(int locationId) async {
    final response = await supabase
        .from('events')
        .select('id, title, description, image_url, location_id, start_time, end_time, created_at, type')
        .eq('location_id', locationId);

    if (response.isEmpty) {
      throw Exception('No se encontraron eventos para esta ubicación.');
    }

    return List<Map<String, dynamic>>.from(response);
  }
}

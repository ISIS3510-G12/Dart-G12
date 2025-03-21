import 'package:supabase_flutter/supabase_flutter.dart';

class LocationRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  LocationRepository();

  /// 🔹 Obtener todas las ubicaciones (excluyendo latitude y longitude)
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category'); // Excluye latitude y longitude

    if (response.isEmpty) {
      throw Exception('No se encontraron ubicaciones.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener ubicaciones donde category = 'Buildings'
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category')
        .eq('category', 'Buildings'); // Filtra por categoría "Buildings"

    if (response.isEmpty) {
      throw Exception('No se encontraron edificios.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener una ubicación por su ID
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category')
        .eq('id', id)
        .maybeSingle(); // Retorna un solo resultado o null

    return response;
  }

  /// 🔹 Obtener ubicaciones con paginación (para listas grandes)
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category')
        .range(start, end); // Paginación en Supabase

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener todos los lugares (`places`) de una `location` específica
  Future<List<Map<String, dynamic>>> fetchPlacesByLocation(int locationId) async {
    final response = await supabase
        .from('places')
        .select('id, id_location, name, url_image, floor')
        .eq('id_location', locationId); // Filtra por id_location

    if (response.isEmpty) {
      throw Exception('No se encontraron lugares para esta ubicación.');
    }

    return List<Map<String, dynamic>>.from(response);
  }
}

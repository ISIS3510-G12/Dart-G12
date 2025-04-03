import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationRepository {
  final supabase = SupabaseService().client;

  LocationRepository();

  /// 🔹 Obtener todas las ubicaciones y ordenarlas por proximidad al usuario
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    // Obtener la ubicación actual del usuario
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    // Obtener todas las ubicaciones desde Supabase
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category, latitude, longitude');

    if (response.isEmpty) {
      throw Exception('No se encontraron ubicaciones.');
    }

    List<Map<String, dynamic>> locations = List<Map<String, dynamic>>.from(response);

    // Ordenar por distancia
    locations.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
          userLat, userLon, a['latitude'], a['longitude']);
      double distanceB = Geolocator.distanceBetween(
          userLat, userLon, b['latitude'], b['longitude']);
      return distanceA.compareTo(distanceB);
    });

    return locations;
  }

  /// 🔹 Obtener ubicaciones donde category = 'Buildings'
  Future<List<Map<String, dynamic>>> fetchBuildings() async {
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category, latitude, longitude')
        .eq('category', 'Buildings');

    if (response.isEmpty) {
      throw Exception('No se encontraron edificios.');
    }

    List<Map<String, dynamic>> buildings = List<Map<String, dynamic>>.from(response);

    // Obtener la ubicación del usuario
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final double userLat = position.latitude;
    final double userLon = position.longitude;

    // Ordenar por distancia
    buildings.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
          userLat, userLon, a['latitude'], a['longitude']);
      double distanceB = Geolocator.distanceBetween(
          userLat, userLon, b['latitude'], b['longitude']);
      return distanceA.compareTo(distanceB);
    });

    return buildings;
  }

  /// 🔹 Obtener una ubicación por su ID
  Future<Map<String, dynamic>?> fetchLocationById(int id) async {
    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category, latitude, longitude')
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  /// 🔹 Obtener ubicaciones con paginación
  Future<List<Map<String, dynamic>>> fetchLocationsPaginated(int page, int limit) async {
    final start = (page - 1) * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from('locations')
        .select('id, name, description, image_url, category, latitude, longitude')
        .range(start, end);

    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener todos los lugares (`places`) de una `location` específica
  Future<List<Map<String, dynamic>>> fetchPlacesByLocation(int locationId) async {
    final response = await supabase
        .from('places')
        .select('id, id_location, name, url_image, floor')
        .eq('id_location', locationId);

    if (response.isEmpty) {
      throw Exception('No se encontraron lugares para esta ubicación.');
    }

    return List<Map<String, dynamic>>.from(response);
  }
}

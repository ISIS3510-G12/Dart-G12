import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static Future<void> logUserAction({
    required String actionType,
    int? eventId,
    String? eventType,
    int? locationId,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('user_actions').insert({
        'user_id': user?.id,
        'action_type': actionType,
        'event_id': eventId,
        'event_type': eventType,
        'location_id': locationId,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Evento registrado con éxito: $actionType, eventId: $eventId, locationId: $locationId');
    } catch (error) {
      print('Error al registrar evento: $error');
    }
  }

  // Función separada para registrar búsquedas de ubicación
  static Future<void> logLocationSearch({
    required int locationId,
    required String locationName,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('user_actions').insert({
        'user_id': user?.id,
        'action_type': 'search_location',
        'event_type': 'search_location',
        'location_id': locationId,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Location search registered: $locationId, $locationName');
    } catch (error) {
      print('Error registering location search: $error');
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

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

      // Si el tipo de acción es 'consult_event', registramos el evento en PostHog
      if (actionType == 'consult_event') {
        await Posthog().capture(
          eventName: 'consult_event', // Nombre del evento
          properties: {
            'event_id': eventId ?? 0,
            'event_type': eventType ?? 0,
            'location_id': locationId ?? 0,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }
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

      // Registrar evento en PostHog correctamente
      await Posthog().capture(
        eventName: 'location_searched', // Nombre del evento
        properties: {
          'location_id': locationId,
          'location_name': locationName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('Location search registered: $locationId, $locationName');
    } catch (error) {
      print('Error registering location search: $error');
    }
  }
}

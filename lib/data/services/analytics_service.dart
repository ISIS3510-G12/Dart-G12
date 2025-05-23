import 'package:posthog_flutter/posthog_flutter.dart';
import 'supabase_service.dart';

class AnalyticsService {
  static Future<void> logUserAction({
    required String actionType,
    int? eventId,
    String? eventType,
    int? locationId,
    String? title
  }) async {
    try {

      // Si el tipo de acción es 'consult_event', registramos el evento en PostHog
      if (actionType == 'consult_event') {
        await Posthog().capture(
          eventName: 'consult_event', // Nombre del evento
          properties: {
            'event_id': eventId ?? 0,
            'event_type': eventType ?? 0,
            'location_id': locationId ?? 0,
            'title': title ?? '',
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

       // Evento genérico de engagement por zona
      if (locationId != null) {
        await Posthog().capture(
          eventName: 'zone_engagement',
          properties: {
            'feature': actionType,
            'location_id': locationId,
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
      // Registar evento en PostHog correctamente
      await Posthog().capture(
        eventName: 'location_searched', // Nombre del evento
        properties: {
          'location_id': locationId,
          'location_name': locationName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Evento de zona engagement
      await Posthog().capture(
        eventName: 'zone_engagement',
        properties: {
          'feature': 'location_search',
          'location_id': locationId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('Location search registered: $locationId, $locationName');
    } catch (error) {
      print('Error registering location search: $error');
    }
  }

  // Función separada para registrar búsquedas de ubicación
  static Future<void> logAppStarted({
    String user_id = "0",

  }) async {
    try {
      await Posthog().capture(
        eventName: 'app_started', // Nombre del evento
        properties: {
          'user_id': user_id,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('App start registered');
    } catch (error) {
      print('Error registering app started: $error');
    }
  }

  static Future<void> logFeatureInteraction({
    required String feature,
  }) async {
    try {
      await Posthog().capture(
        eventName: 'feature_interaction',
        properties: {
          'feature': feature,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('Feature interaction registered: $feature');
    } catch (error) {
      print('Error registering feature interaction: $error');
    }
  }

  static Future<void> logConsultSeeAll({
    required String content_Type,
  }) async {
    try {
      await Posthog().capture(
        eventName: 'open_see_all',
        properties: {
          'content_type': content_Type,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('Enter see all registered: $content_Type');
    } catch (error) {
      print('Error registering enter see all: $error');
    }
  }

  static Future<void> logConsultService({
    required String name,
  }) async {
    try {
      await Posthog().capture(
        eventName: 'consult_service',
        properties: {
          'name': name,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      print('Enter see all service: $name');
    } catch (error) {
      print('Error registering enter see all service: $error');
    }
  }

  static Future<void> logCustomAction({
    String? type, // Nuevo campo para 'type'
    String? enterp, // Nuevo campo para 'enterp'
  }) async {
    try {
      await SupabaseService().client.from('user_actions').insert({
        'type': type,  
        'information_id': enterp,  
      });

      print('Custom action registered: type: $type, enterp: $enterp');
    } catch (error) {
      print('Error registering custom action: $error');
    }
  }



}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String eventName,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime eventDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final tz.TZDateTime notifyDate =
        eventDate.subtract(const Duration(days: 1));

    // Formatear la fecha y hora: ej. "23/05/2025 a las 18:30"
    final String formattedDate =
        '${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year} a las '
        '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';

    try {
      if (eventDate.isBefore(now)) {
        // Mensaje para evento que ya pasó
        final String bodyPassed =
            'Lo lamentamos, pero el evento "$eventName" ya se realizó el $formattedDate.';

        flutterLocalNotificationsPlugin.show(
          id,
          title,
          bodyPassed,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channelId',
              'channelName',
              channelDescription: 'Descripción del canal',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
        );
      } else {
        // Mensaje para evento futuro
        final String bodyFuture =
            'Recuerda que "$eventName" empieza el $formattedDate.';

        final tz.TZDateTime scheduledNotifyDate = notifyDate.isBefore(now)
            ? now.add(const Duration(minutes: 1))
            : notifyDate;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          bodyFuture,
          scheduledNotifyDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channelId',
              'channelName',
              channelDescription: 'Descripción del canal',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('Notificación programada para: $scheduledNotifyDate');
      }
    } catch (e) {
      debugPrint('Error al programar notificación: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

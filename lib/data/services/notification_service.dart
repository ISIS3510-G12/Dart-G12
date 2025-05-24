import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 nuevo import
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  bool _isRequestingPermission = false;

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
    await _requestPermissionIfNeeded(); 
  }

  
  Future<void> _requestPermissionIfNeeded() async {
    if (_isRequestingPermission) return;
      _isRequestingPermission = true;

      try {
        final status = await Permission.notification.status;

        if (status.isDenied || status.isRestricted) {
          await Permission.notification.request();
        }
      } catch (e) {
        debugPrint('Error solicitando permiso: $e');
      } finally {
        _isRequestingPermission = false;
      }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String eventName,
    required DateTime scheduledDate,
  }) async {
    await _requestPermissionIfNeeded(); // 👈 pedir permiso antes de notificar

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime eventDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final tz.TZDateTime notifyDate = eventDate.subtract(const Duration(days: 1));

    final String formattedDate =
        '${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year} a las '
        '${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';

    try {
      if (eventDate.isBefore(now)) {
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

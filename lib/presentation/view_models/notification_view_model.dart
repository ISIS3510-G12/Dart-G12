import 'dart:async';
import 'dart:developer';
import 'package:dart_g12/data/repositories/favorite_repository.dart';
import 'package:flutter/material.dart';
import 'package:dart_g12/data/repositories/event_repository.dart';  // Importa tu repositorio
import 'package:intl/intl.dart';  // Para formatear las fechas
import 'package:geolocator/geolocator.dart';
import 'package:table_calendar/table_calendar.dart';

class NotificacionViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  DateTime _selectedDay = DateTime.utc(2025, 3, 5);

  Map<DateTime, List<Map<String, dynamic>>> get events => _events;
  DateTime get selectedDay => _selectedDay;

  NotificacionViewModel() {
    _loadEvents();
  }

  /// Cargar los eventos desde el repositorio
Future<void> _loadEvents() async {
  try {
    final events = await _favoriteRepository.getFavoriteEvents();

    Map<DateTime, List<Map<String, dynamic>>> groupedEvents = {};

    for (var event in events) {
      // Asegúrate de que el campo exista y sea un String
      final startTimeStr = event['start_time'];
      if (startTimeStr is! String) continue;

      DateTime startTime = DateTime.parse(startTimeStr);
      DateTime eventDate = DateTime(startTime.year, startTime.month, startTime.day);

      groupedEvents.putIfAbsent(eventDate, () => []);
      groupedEvents[eventDate]!.add(event);
    }

    _events = groupedEvents;
    log("Eventos cargados: $_events");
    notifyListeners();
  } catch (e) {
    print("Error cargando eventos: $e");
  }
}


  // Cambiar el día seleccionado
  void setSelectedDay(DateTime selectedDay) {
    _selectedDay = selectedDay;
    notifyListeners();
  }

    void setCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    notifyListeners();
  }
}

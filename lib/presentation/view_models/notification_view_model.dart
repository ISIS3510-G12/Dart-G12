import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dart_g12/data/repositories/event_repository.dart';  // Importa tu repositorio
import 'package:intl/intl.dart';  // Para formatear las fechas
import 'package:geolocator/geolocator.dart';
import 'package:table_calendar/table_calendar.dart';

class NotificacionViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
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
      final events = await _eventRepository.fetchEvents();

      Map<DateTime, List<Map<String, dynamic>>> groupedEvents = {};

      for (var event in events) {
        DateTime startTime = DateTime.parse(event['start_time']);
        DateTime eventDate = DateTime.utc(startTime.year, startTime.month, startTime.day);

        if (!groupedEvents.containsKey(eventDate)) {
          groupedEvents[eventDate] = [];
        }
        groupedEvents[eventDate]!.add(event);
      }

      _events = groupedEvents;
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

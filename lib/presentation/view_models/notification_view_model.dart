import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer';
import 'package:dart_g12/data/repositories/favorite_repository.dart';

class NotificacionViewModel extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  DateTime _selectedDay = DateTime.utc(2025, 3, 5);

  Map<DateTime, List<Map<String, dynamic>>> get events => _events;
  DateTime get selectedDay => _selectedDay;

  NotificacionViewModel() {
    _loadFavoriteEvents();
  }

  Future<void> _loadFavoriteEvents() async {
    try {
      final allFavorites = await _favoriteRepository.getFavorites();
      final eventFavorites = allFavorites.where((item) => item['type'] == 'event').toList();

      
      Map<DateTime, List<Map<String, dynamic>>> groupedEvents = {};

      for (var event in eventFavorites) {
        if (event['start_time'] == null) continue;

        DateTime startTime = DateTime.tryParse(event['start_time']) ?? DateTime.now();
        DateTime eventDate = DateTime.utc(startTime.year, startTime.month, startTime.day);

        groupedEvents.putIfAbsent(eventDate, () => []);
        groupedEvents[eventDate]!.add(event);
      }

      _events = groupedEvents;
      notifyListeners();
    } catch (e) {
      log("Error cargando eventos favoritos: $e");
    }
  }

  void setSelectedDay(DateTime selectedDay) {
    _selectedDay = selectedDay;
    notifyListeners();
  }

  void setCalendarFormat(CalendarFormat format) {
    calendarFormat = format;
    notifyListeners();
  }
}

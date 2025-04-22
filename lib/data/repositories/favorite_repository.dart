import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteRepository {
  
  Future<void> saveFavoriteEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_events') ?? [];
    String eventJson = json.encode(event);
    favorites.add(eventJson);
    await prefs.setStringList('favorite_events', favorites);
  }

  Future<List<Map<String, dynamic>>> getFavoriteEvents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_events') ?? [];
    return favorites.map((eventJson) => json.decode(eventJson) as Map<String, dynamic>).toList();
  }

  Future<void> removeFavoriteEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_events') ?? [];
    String eventJson = json.encode(event);
    favorites.remove(eventJson); 
    await prefs.setStringList('favorite_events', favorites);
  }
}

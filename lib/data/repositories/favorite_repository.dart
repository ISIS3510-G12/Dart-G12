import 'dart:convert';
import '../services/sqlite_service.dart';

class FavoriteRepository {
  final SQLiteService _db = SQLiteService();

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final result = await _db.fetchAll('favorites');

    return result.map((e) {
      final rawData = e['data'];
      if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (e) {
          return <String, dynamic>{}; 
        }
      }
      return <String, dynamic>{};
    }).where((item) => item.isNotEmpty).toList();
  }

  Future<void> saveFavorite(Map<String, dynamic> item) async {
    final itemId = item['id'].toString();
    await _db.insert('favorites', {
      'id': itemId,
      'data': jsonEncode(item),
    });
  }

  Future<void> removeFavorite(dynamic id) async {
    final idStr = id.toString();
    await _db.delete('favorites', 'id = ?', [idStr]);
  }

  Future<List<Map<String, dynamic>>> toggleFavorite(Map<String, dynamic> item) async {
    final id = item['id'].toString();
    final exists = await isFavorite(id);
    if (exists) {
      await removeFavorite(id);
    } else {
      await saveFavorite(item);
    }
    return await getFavorites();
  }

  Future<bool> isFavorite(dynamic id) async {
    final idStr = id.toString();
    final result = await _db.query('favorites', where: 'id = ?', whereArgs: [idStr]);
    return result.isNotEmpty;
  }
}

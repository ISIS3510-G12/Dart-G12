import 'dart:developer';

import '../services/local_storage_service.dart';

class FavoriteRepository {
  static const String _key = 'favorites';

  final LocalStorageService _storage = LocalStorageService();

  Future<List<Map<String, dynamic>>> getFavorites() async {
    return await _storage.fetch(_key);
  }

  /// Guarda la lista completa de favoritos.
  Future<void> _saveAll(List<Map<String, dynamic>> items) async {
    await _storage.save(_key, items);
  }

  /// Agrega un nuevo favorito (si no está ya).
  Future<void> saveFavorite(Map<String, dynamic> item) async {
    final current = await getFavorites();
    final itemId = item['id'].toString(); 
    final exists = current.any((f) => f['id'].toString() == itemId);

    if (!exists) {
      current.add(item);
      await _saveAll(current);
      log('Favorito agregado: $itemId');
    }
  }

  /// Elimina un favorito según su 'id'.
  Future<void> removeFavorite(dynamic id) async {
    final current = await getFavorites();
    final idStr = id.toString(); // Aseguramos comparación por string
    current.removeWhere((f) => f['id'].toString() == idStr);
    await _saveAll(current);
    log('Favorito eliminado: $idStr');
  }

  /// Alterna un favorito: si existe lo quita, si no lo agrega.
  /// Devuelve la lista actualizada.
  Future<List<Map<String, dynamic>>> toggleFavorite(
      Map<String, dynamic> item) async {
    final current = await getFavorites();
    final exists = current.any((f) => f['id'] == item['id']);
    if (exists) {
      current.removeWhere((f) => f['id'] == item['id']);
    } else {
      current.add(item);
    }
    await _saveAll(current);
    return current;
  }

  /// Verifica si un elemento con [id] está en favoritos.
  Future<bool> isFavorite(dynamic id) async {
    final current = await getFavorites();
    return current.any((f) => f['id'] == (id is String ? int.tryParse(id) : id));
  }
}

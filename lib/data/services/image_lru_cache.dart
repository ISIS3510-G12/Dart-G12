import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageCacheLRU {
  final LruMap<String, Uint8List> _cache;

  ImageCacheLRU({int maxSize = 20}) : _cache = LruMap(capacity: maxSize);

  Future<Uint8List> loadImage(String url) async {
    if (_cache.containsKey(url)) {
      return _cache.get(url)!;
    } else {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _cache.put(url, response.bodyBytes);
        return response.bodyBytes;
      } else {
        throw Exception('Error cargando imagen: $url');
      }
    }
  }
}

class LruMap<K, V> {
  final int capacity;
  final _cache = <K, V>{};
  final _usage = <K>[];

  LruMap({required this.capacity});

  V? get(K key) {
    if (_cache.containsKey(key)) {
      _usage.remove(key);
      _usage.insert(0, key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _usage.remove(key);
    } else if (_cache.length >= capacity) {
      final lruKey = _usage.removeLast();
      _cache.remove(lruKey);
    }
    _cache[key] = value;
    _usage.insert(0, key);
  }

  bool containsKey(K key) => _cache.containsKey(key);
}

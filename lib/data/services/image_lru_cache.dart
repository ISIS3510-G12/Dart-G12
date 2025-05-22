import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageCacheLRU {
  final LruMap<String, Uint8List> _cache;
  final int capacity;

  ImageCacheLRU({this.capacity = 20}) : _cache = LruMap(capacity: capacity);

  // Directorio para cache local
  Future<Directory> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    return cacheDir;
  }

  // Nombre de archivo basado en md5 del url
  String _fileNameForUrl(String url) {
    final bytes = utf8.encode(url);
    return md5.convert(bytes).toString();
  }

  Future<File> _fileForUrl(String url) async {
    final dir = await _cacheDir;
    final name = _fileNameForUrl(url);
    return File('${dir.path}/$name');
  }

  Future<Uint8List> loadImage(String url) async {
    // 1) Cache en memoria
    if (_cache.containsKey(url)) {
      return _cache.get(url)!;
    }

    // 2) Cache en disco
    final file = await _fileForUrl(url);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      _cache.put(url, bytes);
      return bytes;
    }

    // 3) Descargar y guardar
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Guardar en disco
      await file.writeAsBytes(bytes);

      // Guardar en cache memoria
      _cache.put(url, bytes);
      return bytes;
    }

    throw Exception('No se pudo cargar la imagen: $url');
  }
}

// Implementación simple del LRU Map
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

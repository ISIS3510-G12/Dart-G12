import 'package:hive/hive.dart';

class HiveStorageService {
  Future<List<Map<String, dynamic>>> fetch(String key) async {
    final box = await Hive.openBox('cacheBox');
    final raw = box.get(key);
    if (raw != null && raw is List) {
      return List<Map<String, dynamic>>.from(raw);
    }
    return [];
  }

  Future<void> save(String key, List<Map<String, dynamic>> data) async {
    final box = await Hive.openBox('cacheBox');
    await box.put(key, data);
  }
}

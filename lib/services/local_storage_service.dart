import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _cachebox = 'cache-box';
  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  Future<String?> find(String key) async {
    final box = await Hive.openBox<String>(_cachebox);
    return box.get(key);
  }

  Future<bool> save(String key, String data) async {
    try {
      final box = await Hive.openBox<String>(_cachebox);
      await box.put(key, data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> remove(String key) async {
    try {
      final box = await Hive.openBox<String>(_cachebox);
      await box.delete(key);
      return true;
    } catch (e) {
      return false;
    }
  }
}

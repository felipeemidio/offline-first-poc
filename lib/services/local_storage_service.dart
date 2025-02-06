import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _cachebox = 'cache-box';
  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  Future<List<String>> getAll() async {
    final box = await Hive.openBox<String>(_cachebox);
    return List<String>.from(box.keys);
  }

  Future<String?> get(String key) async {
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

  Future<bool> clear() async {
    try {
      final box = await Hive.openBox<String>(_cachebox);
      await box.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getList(String key) async {
    try {
      final box = await Hive.openBox<String>(_cachebox);
      final rawList = box.get(key) ?? '[]';
      return List<String>.from(jsonDecode(rawList));
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addInList(String key, String data) async {
    try {
      final list = await getList(key);
      list.add(data);
      return await save(key, jsonEncode(list));
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAtList(String key, int index, String data) async {
    try {
      final list = await getList(key);
      list[index] = data;

      return await save(key, jsonEncode(list));
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromList(String key, String data) async {
    try {
      final list = await getList(key);
      final exists = list.remove(data);

      return exists ? await save(key, jsonEncode(list)) : true;
    } catch (e) {
      return false;
    }
  }
}

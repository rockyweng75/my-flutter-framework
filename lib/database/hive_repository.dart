import 'package:hive_flutter/hive_flutter.dart';

class HiveRepository {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = getBox(boxName);
    await box.put(key, value);
  }

  static dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<void> delete(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  static T? getAsModel<T>(
    String boxName,
    String key, {
    required T Function(Map<String, dynamic>) fromMap,
    dynamic defaultValue,
  }) {
    final box = getBox(boxName);
    final data = box.get(key, defaultValue: defaultValue);
    if (data is Map<String, dynamic>) {
      return fromMap(data);
    }
    return null;
  }

  /// 儲存 model（自動轉成 Map）
  static Future<void> putModel(
    String boxName,
    String key,
    Map<String, dynamic> Function() toMap,
  ) async {
    final box = getBox(boxName);
    await box.put(key, toMap());
  }
}

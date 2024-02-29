import 'package:hive_flutter/hive_flutter.dart';

import './storage_service.dart';

/// Implementation of [StorageService] with [Hive]
class HiveStorageService extends StorageService {
  late Box<dynamic> hiveBox;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    await openBox('Salt-Strong App');
  }

  Future<void> openBox(String boxName) async {
    hiveBox = await Hive.openBox(boxName);
  }

  Future<void> closeBox() async {
    await hiveBox.close();
  }

  @override
  Future<void> deleteValue(String key) async {
    await hiveBox.delete(key);
  }

  @override
  String? getValue(String key) => hiveBox.get(key) as String?;

  @override
  dynamic getAll() => hiveBox.values.toList();

  @override
  bool hasValue(String key) => hiveBox.containsKey(key);

  @override
  Future<void> setValue({required String key, required String? data}) async {
    await hiveBox.put(key, data);
  }

  @override
  Future<void> clear() async {
    await hiveBox.clear();
  }
}

import 'package:hive_flutter/hive_flutter.dart';

import 'package:core/core.dart';

class HiveCacheService implements ICacheService {
  bool _isInitialized = false;
  final Set<String> _openedBoxes = {};

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _isInitialized = true;
  }

  Box<T> _getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  Future<Box<T>> _openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      _openedBoxes.add(boxName);
      return Hive.box<T>(boxName);
    }
    final box = await Hive.openBox<T>(boxName);
    _openedBoxes.add(boxName);
    return box;
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await _openBox<T>(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>(String boxName, String key) {
    if (!Hive.isBoxOpen(boxName)) return null;
    final box = _getBox<T>(boxName);
    return box.get(key);
  }

  @override
  Future<void> delete(String boxName, String key) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.clear();
  }

  @override
  Future<void> clearAll() async {
    for (final boxName in _openedBoxes) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.clear();
      }
    }
  }

  @override
  bool containsKey(String boxName, String key) {
    if (!Hive.isBoxOpen(boxName)) return false;
    final box = _getBox(boxName);
    return box.containsKey(key);
  }
}

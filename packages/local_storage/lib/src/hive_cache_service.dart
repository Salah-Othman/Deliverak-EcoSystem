import 'package:hive_flutter/hive_flutter.dart';

import 'package:core/core.dart';

class HiveCacheService implements ICacheService {
  bool _isInitialized = false;
  final Set<String> _openedBoxNames = {};
  final Map<String, Box<dynamic>> _boxCache = {};

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _isInitialized = true;
  }

  Future<Box<T>> _openBox<T>(String boxName) async {
    if (_boxCache.containsKey(boxName)) {
      return _boxCache[boxName]! as Box<T>;
    }
    final box = await Hive.openBox<T>(boxName);
    _openedBoxNames.add(boxName);
    _boxCache[boxName] = box;
    return box;
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await _openBox<T>(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>(String boxName, String key) {
    final box = _boxCache[boxName];
    if (box == null) return null;
    return box.get(key) as T?;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = _boxCache[boxName];
    if (box == null) return;
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = _boxCache[boxName];
    if (box == null) return;
    await box.clear();
  }

  @override
  Future<void> clearAll() async {
    for (final box in _boxCache.values) {
      await box.clear();
    }
  }

  @override
  bool containsKey(String boxName, String key) {
    final box = _boxCache[boxName];
    if (box == null) return false;
    return box.containsKey(key);
  }
}

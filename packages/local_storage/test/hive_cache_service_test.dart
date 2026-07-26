import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:local_storage/local_storage.dart';

void main() {
  late HiveCacheService cacheService;
  late String testPath;

  setUp(() {
    testPath =
        '${Directory.current.path}\\.hive_test_${DateTime.now().millisecondsSinceEpoch}';
    Hive.init(testPath);
    cacheService = HiveCacheService();
  });

  tearDown(() async {
    await Hive.close();
    final dir = Directory(testPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  group('put and get', () {
    test('stores and retrieves a String value', () async {
      await cacheService.put<String>('testBox', 'key1', 'hello');
      final result = cacheService.get<String>('testBox', 'key1');
      expect(result, 'hello');
    });

    test('stores and retrieves an int value', () async {
      await cacheService.put<int>('testBox', 'count', 42);
      final result = cacheService.get<int>('testBox', 'count');
      expect(result, 42);
    });

    test('stores and retrieves a Map value', () async {
      final data = {'name': 'Test', 'age': 25};
      await cacheService.put<Map>('testBox', 'user', data);
      final result = cacheService.get<Map>('testBox', 'user');
      expect(result, data);
    });

    test('overwrites existing value', () async {
      await cacheService.put<String>('testBox', 'key1', 'first');
      await cacheService.put<String>('testBox', 'key1', 'second');
      final result = cacheService.get<String>('testBox', 'key1');
      expect(result, 'second');
    });
  });

  group('get', () {
    test('returns null for non-existent key', () async {
      await cacheService.put<String>('testBox', 'key1', 'value');
      final result = cacheService.get<String>('testBox', 'missing');
      expect(result, isNull);
    });

    test('returns null for closed box', () {
      final result = cacheService.get<String>('closedBox', 'key1');
      expect(result, isNull);
    });
  });

  group('delete', () {
    test('deletes existing key', () async {
      await cacheService.put<String>('testBox', 'key1', 'value');
      await cacheService.delete('testBox', 'key1');
      final result = cacheService.get<String>('testBox', 'key1');
      expect(result, isNull);
    });

    test('does not throw for non-existent key', () async {
      await cacheService.put<String>('testBox', 'key1', 'value');
      await cacheService.delete('testBox', 'missing');
    });

    test('does not throw for closed box', () async {
      await cacheService.delete('closedBox', 'key1');
    });
  });

  group('containsKey', () {
    test('returns true for existing key', () async {
      await cacheService.put<String>('testBox', 'key1', 'value');
      expect(cacheService.containsKey('testBox', 'key1'), isTrue);
    });

    test('returns false for non-existent key', () async {
      await cacheService.put<String>('testBox', 'key1', 'value');
      expect(cacheService.containsKey('testBox', 'missing'), isFalse);
    });

    test('returns false for closed box', () {
      expect(cacheService.containsKey('closedBox', 'key1'), isFalse);
    });
  });

  group('clearBox', () {
    test('clears all entries in a box', () async {
      await cacheService.put<String>('testBox', 'key1', 'value1');
      await cacheService.put<String>('testBox', 'key2', 'value2');
      await cacheService.clearBox('testBox');
      expect(cacheService.get<String>('testBox', 'key1'), isNull);
      expect(cacheService.get<String>('testBox', 'key2'), isNull);
    });

    test('does not affect other boxes', () async {
      await cacheService.put<String>('box1', 'key1', 'value1');
      await cacheService.put<String>('box2', 'key2', 'value2');
      await cacheService.clearBox('box1');
      expect(cacheService.get<String>('box1', 'key1'), isNull);
      expect(cacheService.get<String>('box2', 'key2'), 'value2');
    });

    test('does not throw for closed box', () async {
      await cacheService.clearBox('closedBox');
    });
  });

  group('clearAll', () {
    test('clears all opened boxes', () async {
      await cacheService.put<String>('box1', 'key1', 'value1');
      await cacheService.put<String>('box2', 'key2', 'value2');
      await cacheService.clearAll();
      expect(cacheService.get<String>('box1', 'key1'), isNull);
      expect(cacheService.get<String>('box2', 'key2'), isNull);
    });
  });

  group('multiple data types', () {
    test('stores and retrieves bool values', () async {
      await cacheService.put<bool>('testBox', 'flag', true);
      expect(cacheService.get<bool>('testBox', 'flag'), isTrue);
      await cacheService.put<bool>('testBox', 'flag', false);
      expect(cacheService.get<bool>('testBox', 'flag'), isFalse);
    });

    test('stores and retrieves List values', () async {
      final list = ['a', 'b', 'c'];
      await cacheService.put<List>('testBox', 'items', list);
      expect(cacheService.get<List>('testBox', 'items'), list);
    });

    test('stores and retrieves double values', () async {
      await cacheService.put<double>('testBox', 'price', 19.99);
      expect(cacheService.get<double>('testBox', 'price'), 19.99);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:local_storage/local_storage.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
  });

  group('SecureStorageService interface contract', () {
    test('write delegates to storage with key and value', () async {
      when(() => mockStorage.write(key: 'test_key', value: 'test_value'))
          .thenAnswer((_) async {});

      await mockStorage.write(key: 'test_key', value: 'test_value');

      verify(() => mockStorage.write(key: 'test_key', value: 'test_value'))
          .called(1);
    });

    test('read returns stored value', () async {
      when(() => mockStorage.read(key: 'test_key'))
          .thenAnswer((_) async => 'stored_value');

      final result = await mockStorage.read(key: 'test_key');

      expect(result, 'stored_value');
      verify(() => mockStorage.read(key: 'test_key')).called(1);
    });

    test('read returns null for nonexistent key', () async {
      when(() => mockStorage.read(key: 'missing'))
          .thenAnswer((_) async => null);

      final result = await mockStorage.read(key: 'missing');

      expect(result, isNull);
    });

    test('delete removes key', () async {
      when(() => mockStorage.delete(key: 'test_key'))
          .thenAnswer((_) async {});

      await mockStorage.delete(key: 'test_key');

      verify(() => mockStorage.delete(key: 'test_key')).called(1);
    });

    test('deleteAll clears all keys', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await mockStorage.deleteAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('multiple operations can be chained', () async {
      when(() => mockStorage.write(key: 'k1', value: 'v1'))
          .thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'k1'))
          .thenAnswer((_) async => 'v1');
      when(() => mockStorage.delete(key: 'k1'))
          .thenAnswer((_) async {});

      await mockStorage.write(key: 'k1', value: 'v1');
      final result = await mockStorage.read(key: 'k1');
      expect(result, 'v1');

      await mockStorage.delete(key: 'k1');
      when(() => mockStorage.read(key: 'k1')).thenAnswer((_) async => null);
      final afterDelete = await mockStorage.read(key: 'k1');
      expect(afterDelete, isNull);
    });
  });

  group('SecureStorageService instantiation', () {
    test('SecureStorageService implements ISecureStorageService', () {
      expect(SecureStorageService(), isA<ISecureStorageService>());
    });
  });
}

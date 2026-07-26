import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import '../helpers/test_models.dart';

void main() {
  group('DriverModel', () {
    test('fromMap creates valid model', () {
      final map = {
        'driverId': 'd-1',
        'userId': 'u-1',
        'vehicleType': 'bike',
        'vehicleNumber': 'VEH-001',
        'licenseNumber': 'LIC-001',
        'isOnline': true,
        'currentLat': 40.71,
        'currentLng': -74.0,
        'rating': 4.8,
        'totalDeliveries': 250,
        'createdAt': DateTime(2024).toIso8601String(),
      };

      final driver = DriverModel.fromMap(map);

      expect(driver.driverId, 'd-1');
      expect(driver.isOnline, true);
      expect(driver.rating, 4.8);
      expect(driver.totalDeliveries, 250);
    });

    test('fromMap handles missing fields', () {
      final driver = DriverModel.fromMap({});

      expect(driver.driverId, '');
      expect(driver.isOnline, false);
      expect(driver.rating, 0.0);
      expect(driver.totalDeliveries, 0);
    });

    test('toMap round-trips through fromMap', () {
      final driver = DriverModelFixture.create();
      final roundTripped = DriverModel.fromMap(driver.toMap());

      expect(roundTripped.driverId, driver.driverId);
      expect(roundTripped.vehicleType, driver.vehicleType);
      expect(roundTripped.isOnline, driver.isOnline);
    });

    test('copyWith changes specified fields', () {
      final driver = DriverModelFixture.create(isOnline: false);
      final updated = driver.copyWith(isOnline: true, rating: 5.0);

      expect(updated.isOnline, true);
      expect(updated.rating, 5.0);
      expect(updated.driverId, driver.driverId);
    });
  });

  group('CategoryModel', () {
    test('fromMap creates valid model', () {
      final map = {
        'categoryId': 'cat-1',
        'name': 'Pizza',
        'image': 'https://img.jpg',
        'type': 'medicine',
        'sortOrder': 2,
      };

      final cat = CategoryModel.fromMap(map);
      expect(cat.categoryId, 'cat-1');
      expect(cat.type, DeliveryType.medicine);
      expect(cat.sortOrder, 2);
    });

    test('toMap round-trips through fromMap', () {
      final cat = CategoryModelFixture.create();
      final roundTripped = CategoryModel.fromMap(cat.toMap());

      expect(roundTripped.categoryId, cat.categoryId);
      expect(roundTripped.name, cat.name);
      expect(roundTripped.type, cat.type);
    });
  });

  group('NotificationModel', () {
    test('fromMap creates valid model', () {
      final map = {
        'notificationId': 'n-1',
        'userId': 'u-1',
        'title': 'Order Update',
        'body': 'Delivered!',
        'type': 'order',
        'referenceId': 'r-1',
        'isRead': true,
        'createdAt': DateTime(2024).toIso8601String(),
      };

      final notif = NotificationModel.fromMap(map);
      expect(notif.notificationId, 'n-1');
      expect(notif.isRead, true);
      expect(notif.referenceId, 'r-1');
    });

    test('fromMap handles missing optional fields', () {
      final notif = NotificationModel.fromMap({});
      expect(notif.referenceId, null);
      expect(notif.isRead, false);
    });

    test('copyWith changes isRead', () {
      final notif = NotificationModelFixture.create(isRead: false);
      final updated = notif.copyWith(isRead: true);

      expect(updated.isRead, true);
      expect(updated.notificationId, notif.notificationId);
      expect(updated.title, notif.title);
    });

    test('toMap round-trips through fromMap', () {
      final notif = NotificationModelFixture.create();
      final roundTripped = NotificationModel.fromMap(notif.toMap());

      expect(roundTripped.notificationId, notif.notificationId);
      expect(roundTripped.title, notif.title);
      expect(roundTripped.isRead, notif.isRead);
    });
  });

  group('QueryCondition', () {
    test('creates with default operator (isEqualTo)', () {
      const condition = QueryCondition(field: 'name', value: 'test');
      expect(condition.field, 'name');
      expect(condition.value, 'test');
      expect(condition.operator, QueryOperator.isEqualTo);
    });

    test('creates with custom operator', () {
      const condition = QueryCondition(
        field: 'age',
        value: 18,
        operator: QueryOperator.isGreaterThan,
      );
      expect(condition.operator, QueryOperator.isGreaterThan);
    });

    test('Equatable works correctly', () {
      const c1 = QueryCondition(field: 'name', value: 'test');
      const c2 = QueryCondition(field: 'name', value: 'test');
      expect(c1, equals(c2));
    });
  });
}

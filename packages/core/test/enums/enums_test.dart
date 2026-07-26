import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('UserRole', () {
    test('has expected values', () {
      expect(UserRole.values, containsAll([
        UserRole.customer,
        UserRole.driver,
        UserRole.vendor,
        UserRole.admin,
      ]));
    });

    test('displayName returns correct values', () {
      expect(UserRole.customer.displayName, 'Customer');
      expect(UserRole.driver.displayName, 'Driver');
      expect(UserRole.vendor.displayName, 'Vendor');
      expect(UserRole.admin.displayName, 'Admin');
    });
  });

  group('OrderStatus', () {
    test('has expected values', () {
      expect(OrderStatus.values.length, 7);
      expect(OrderStatus.values, containsAll([
        OrderStatus.pending,
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.pickedUp,
        OrderStatus.inTransit,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ]));
    });

    test('displayName returns correct values', () {
      expect(OrderStatus.pending.displayName, 'Pending');
      expect(OrderStatus.accepted.displayName, 'Accepted');
      expect(OrderStatus.preparing.displayName, 'Preparing');
      expect(OrderStatus.pickedUp.displayName, 'Picked Up');
      expect(OrderStatus.inTransit.displayName, 'In Transit');
      expect(OrderStatus.delivered.displayName, 'Delivered');
      expect(OrderStatus.cancelled.displayName, 'Cancelled');
    });

    test('isActive returns true for active statuses', () {
      expect(OrderStatus.pending.isActive, true);
      expect(OrderStatus.accepted.isActive, true);
      expect(OrderStatus.preparing.isActive, true);
      expect(OrderStatus.pickedUp.isActive, true);
      expect(OrderStatus.inTransit.isActive, true);
    });

    test('isActive returns false for terminal statuses', () {
      expect(OrderStatus.delivered.isActive, false);
      expect(OrderStatus.cancelled.isActive, false);
    });
  });

  group('DeliveryType', () {
    test('has expected values', () {
      expect(DeliveryType.values.length, 4);
      expect(DeliveryType.values, containsAll([
        DeliveryType.food,
        DeliveryType.grocery,
        DeliveryType.medicine,
        DeliveryType.package,
      ]));
    });

    test('displayName returns correct values', () {
      expect(DeliveryType.food.displayName, 'Food');
      expect(DeliveryType.grocery.displayName, 'Grocery');
      expect(DeliveryType.medicine.displayName, 'Medicine');
      expect(DeliveryType.package.displayName, 'Package');
    });
  });
}

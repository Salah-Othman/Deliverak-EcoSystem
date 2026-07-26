import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import '../helpers/test_models.dart';

void main() {
  group('OrderItem', () {
    test('total returns quantity * price', () {
      final item = OrderModelFixture.createOrderItem(quantity: 3, price: 10.0);
      expect(item.total, 30.0);
    });

    test('fromMap creates valid item', () {
      final map = {
        'productId': 'p-1',
        'name': 'Fries',
        'quantity': 2,
        'price': 4.99,
      };

      final item = OrderItem.fromMap(map);
      expect(item.productId, 'p-1');
      expect(item.name, 'Fries');
      expect(item.quantity, 2);
      expect(item.price, 4.99);
    });

    test('toMap round-trips through fromMap', () {
      final item = OrderModelFixture.createOrderItem();
      final roundTripped = OrderItem.fromMap(item.toMap());

      expect(roundTripped.productId, item.productId);
      expect(roundTripped.name, item.name);
      expect(roundTripped.quantity, item.quantity);
      expect(roundTripped.price, item.price);
    });
  });

  group('DeliveryAddress', () {
    test('fromMap creates valid address', () {
      final map = {
        'lat': 40.7128,
        'lng': -74.006,
        'address': '123 Main St',
        'name': 'John',
        'phone': '+1234567890',
      };

      final addr = DeliveryAddress.fromMap(map);
      expect(addr.lat, 40.7128);
      expect(addr.address, '123 Main St');
    });

    test('toMap round-trips through fromMap', () {
      final addr = OrderModelFixture.createDeliveryAddress();
      final roundTripped = DeliveryAddress.fromMap(addr.toMap());

      expect(roundTripped.lat, addr.lat);
      expect(roundTripped.lng, addr.lng);
      expect(roundTripped.address, addr.address);
    });
  });

  group('OrderModel', () {
    test('fromMap creates valid order with nested items', () {
      final now = DateTime(2024);
      final map = {
        'orderId': 'order-1',
        'customerId': 'cust-1',
        'vendorId': 'vend-1',
        'driverId': 'drv-1',
        'items': [
          {'productId': 'p-1', 'name': 'Burger', 'quantity': 2, 'price': 9.99},
        ],
        'totalAmount': 22.97,
        'deliveryFee': 2.99,
        'status': 'preparing',
        'deliveryAddress': {
          'lat': 40.71,
          'lng': -74.0,
          'address': '123 Main',
          'name': 'John',
          'phone': '+123',
        },
        'paymentMethod': 'cash',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final order = OrderModel.fromMap(map);

      expect(order.orderId, 'order-1');
      expect(order.items.length, 1);
      expect(order.items[0].name, 'Burger');
      expect(order.status, OrderStatus.preparing);
      expect(order.driverId, 'drv-1');
    });

    test('fromMap defaults to pending for unknown status', () {
      final order = OrderModel.fromMap({
        'status': 'unknown',
        'deliveryAddress': <String, dynamic>{},
      });
      expect(order.status, OrderStatus.pending);
    });

    test('toMap round-trips through fromMap', () {
      final order = OrderModelFixture.create();
      final roundTripped = OrderModel.fromMap(order.toMap());

      expect(roundTripped.orderId, order.orderId);
      expect(roundTripped.items.length, order.items.length);
      expect(roundTripped.status, order.status);
      expect(roundTripped.totalAmount, order.totalAmount);
    });

    test('copyWith updates status and sets updatedAt', () {
      final order = OrderModelFixture.create(status: OrderStatus.pending);
      final updated = order.copyWith(status: OrderStatus.accepted);

      expect(updated.status, OrderStatus.accepted);
      expect(updated.orderId, order.orderId);
      expect(updated.updatedAt.isAfter(order.updatedAt), true);
    });

    test('Equatable works correctly', () {
      final o1 = OrderModelFixture.create();
      final o2 = OrderModelFixture.create();
      expect(o1, equals(o2));
    });
  });
}

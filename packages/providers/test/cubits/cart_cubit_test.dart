import 'package:flutter_test/flutter_test.dart';
import 'package:providers/providers.dart';

void main() {
  late CartCubit cubit;

  setUp(() {
    cubit = CartCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('CartCubit', () {
    test('initial state is CartInitial', () {
      expect(cubit.state, isA<CartInitial>());
      expect(cubit.hasItems, false);
      expect(cubit.items, isEmpty);
    });

    test('addItem adds new item and emits CartLoaded', () {
      cubit.addItem(
        productId: 'p1',
        vendorId: 'v1',
        name: 'Burger',
        price: 9.99,
      );

      expect(cubit.state, isA<CartLoaded>());
      expect(cubit.items.length, 1);
      expect(cubit.items[0].quantity, 1);
      expect(cubit.vendorId, 'v1');
    });

    test('addItem increments quantity for existing product', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);

      expect(cubit.items.length, 1);
      expect(cubit.items[0].quantity, 2);
    });

    test('addItem clears cart when different vendor', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.addItem(productId: 'p2', vendorId: 'v2', name: 'Pizza', price: 12.99);

      expect(cubit.items.length, 1);
      expect(cubit.items[0].productId, 'p2');
      expect(cubit.vendorId, 'v2');
    });

    test('removeItem removes item', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.removeItem('p1');

      expect(cubit.items, isEmpty);
      expect(cubit.vendorId, '');
    });

    test('updateQuantity updates item quantity', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.updateQuantity('p1', 5);

      expect(cubit.items[0].quantity, 5);
    });

    test('updateQuantity removes item when quantity <= 0', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.updateQuantity('p1', 0);

      expect(cubit.items, isEmpty);
    });

    test('clearCart empties items and vendorId', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);
      cubit.clearCart();

      expect(cubit.items, isEmpty);
      expect(cubit.vendorId, '');
    });

    test('totalAmount calculates correctly', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 10.00);
      cubit.addItem(productId: 'p2', vendorId: 'v1', name: 'Fries', price: 5.00);

      expect(cubit.totalAmount, 15.00);
    });

    test('grandTotal includes delivery fee', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 10.00);

      expect(cubit.grandTotal, 10.00 + 2.99);
    });

    test('deliveryFee is constant 2.99', () {
      expect(cubit.deliveryFee, 2.99);
    });

    test('hasItemsFromDifferentVendor returns correct value', () {
      cubit.addItem(productId: 'p1', vendorId: 'v1', name: 'Burger', price: 9.99);

      expect(cubit.hasItemsFromDifferentVendor('v1'), false);
      expect(cubit.hasItemsFromDifferentVendor('v2'), true);
    });
  });
}

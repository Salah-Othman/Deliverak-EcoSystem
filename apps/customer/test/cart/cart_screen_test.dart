import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:providers/providers.dart';

import '../helpers/test_app.dart';
import 'package:customer/features/cart/presentation/screens/cart_screen.dart';
import 'package:customer/features/checkout/presentation/screens/checkout_screen.dart';

void main() {
  group('CartScreen', () {
    testWidgets('shows empty cart message when cart is empty', (tester) async {
      await tester.pumpWidget(
        TestApp(child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Add items from vendors to get started'), findsOneWidget);
    });

    testWidgets('shows empty cart icon', (tester) async {
      await tester.pumpWidget(
        TestApp(child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('displays cart items when cart has items', (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Margherita Pizza'), findsOneWidget);
      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('displays subtotal, delivery fee, and total', (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Delivery fee'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('quantity buttons work correctly', (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('remove button shows confirmation dialog at quantity 1',
        (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Remove item'), findsOneWidget);
      expect(find.textContaining('Remove Margherita Pizza'), findsOneWidget);
    });

    testWidgets('confirming remove clears the item', (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('Place Order navigates to CheckoutScreen', (tester) async {
      final cartCubit = CartCubit();
      cartCubit.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(
        TestApp(cartCubit: cartCubit, child: const CartScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutScreen), findsOneWidget);
    });
  });
}

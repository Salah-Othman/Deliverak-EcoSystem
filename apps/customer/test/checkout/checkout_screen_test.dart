import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/checkout/presentation/screens/checkout_screen.dart';

void main() {
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockOrderRepo = MockOrderRepository();
  });

  group('CheckoutScreen', () {
    Widget buildScreen({required CartCubit cartCubit}) {
      final auth = AuthCubit(
        authRepository: TestHelpers.createMockAuthRepository(
          currentUser: TestData.customer,
        ),
      );

      return TestApp(
        cartCubit: cartCubit,
        authCubit: auth,
        orderRepository: mockOrderRepo,
        child: CheckoutScreen(vendorId: 'vendor-1'),
      );
    }

    testWidgets('renders Checkout title', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('displays order summary with items', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.textContaining('Margherita Pizza'), findsWidgets);
    });

    testWidgets('displays subtotal, delivery fee, and total', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Delivery fee'), findsWidgets);
      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('displays delivery address form', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Address'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('displays payment method section', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Pay when your order arrives'), findsOneWidget);
    });

    testWidgets('shows Place Order button with total amount', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.textContaining('Place Order'), findsOneWidget);
    });

    testWidgets('shows validation error on empty name', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Place Order'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows empty cart message when cart is empty', (tester) async {
      final cart = CartCubit();

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('has AppBar with Checkout title', (tester) async {
      final cart = CartCubit();
      cart.addItem(
        productId: 'product-1',
        vendorId: 'vendor-1',
        name: 'Margherita Pizza',
        price: 12.99,
      );

      await tester.pumpWidget(buildScreen(cartCubit: cart));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Checkout'), findsWidgets);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:core/core.dart';
import 'package:providers/providers.dart';
import 'package:vendor/features/orders/presentation/widgets/vendor_order_card.dart';

void main() {
  late MockVendorOrderCubit mockOrderCubit;

  setUp(() {
    mockOrderCubit = MockVendorOrderCubit();
    when(() => mockOrderCubit.state).thenReturn(VendorOrderInitial());
    when(() => mockOrderCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildOrderCard({VoidCallback? onTap}) {
    return MaterialApp(
      home: BlocProvider<VendorOrderCubit>.value(
        value: mockOrderCubit,
        child: Scaffold(
          body: VendorOrderCard(
            order: OrderModel(
              orderId: 'order_1700000000_123',
              customerId: 'c1',
              vendorId: 'v1',
              items: [
                OrderItem(productId: 'p1', name: 'Burger', quantity: 2, price: 9.99),
                OrderItem(productId: 'p2', name: 'Fries', quantity: 1, price: 4.99),
              ],
              totalAmount: 24.97,
              deliveryFee: 2.99,
              status: OrderStatus.pending,
              deliveryAddress: DeliveryAddress(
                lat: 40.7128,
                lng: -74.0060,
                address: '123 Main St',
                name: 'John Doe',
                phone: '+1234567890',
              ),
              paymentMethod: 'cash',
              createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
              updatedAt: DateTime.now(),
            ),
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  group('VendorOrderCard', () {
    testWidgets('renders order ID', (tester) async {
      await tester.pumpWidget(buildOrderCard());
      expect(find.textContaining('Order #'), findsOneWidget);
    });

    testWidgets('renders customer name', (tester) async {
      await tester.pumpWidget(buildOrderCard());
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders item count and total', (tester) async {
      await tester.pumpWidget(buildOrderCard());
      expect(find.textContaining('2 items'), findsOneWidget);
    });

    testWidgets('renders Pending status chip', (tester) async {
      await tester.pumpWidget(buildOrderCard());
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('onTap is called when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildOrderCard(onTap: () => tapped = true));
      await tester.tap(find.byType(VendorOrderCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders different status chips', (tester) async {
      for (final status in [
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ]) {
        await tester.pumpWidget(MaterialApp(
          home: BlocProvider<VendorOrderCubit>.value(
            value: mockOrderCubit,
            child: Scaffold(
              body: VendorOrderCard(
                order: OrderModel(
                  orderId: 'o1',
                  customerId: 'c1',
                  vendorId: 'v1',
                  items: [OrderItem(productId: 'p1', name: 'Burger', quantity: 1, price: 9.99)],
                  totalAmount: 9.99,
                  deliveryFee: 2.99,
                  status: status,
                  deliveryAddress: DeliveryAddress(
                    lat: 0, lng: 0, address: 'addr', name: 'Name', phone: '+1',
                  ),
                  paymentMethod: 'cash',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
                onTap: () {},
              ),
            ),
          ),
        ));
        expect(find.text(status.displayName), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}

class MockVendorOrderCubit extends Mock implements VendorOrderCubit {}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/orders/presentation/screens/order_detail_screen.dart';

void main() {
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockOrderRepo = MockOrderRepository();
  });

  group('OrderDetailScreen', () {
    Widget buildScreen(WidgetTester tester, {OrderModel? order}) {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockOrderRepo.watchOrderResult = order;

      return TestApp(
        orderRepository: mockOrderRepo,
        child: OrderDetailScreen(orderId: order?.orderId ?? 'order-1'),
      );
    }

    testWidgets('renders Order Details title', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsOneWidget);
    });

    testWidgets('displays order header with ID and status', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
    });

    testWidgets('displays order items section', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Items'), findsOneWidget);
      expect(find.textContaining('Margherita Pizza'), findsWidgets);
    });

    testWidgets('displays delivery address section', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('123 Main St, New York, NY 10001'), findsOneWidget);
    });

    testWidgets('displays payment section', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('displays status stepper', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
      expect(find.text('Delivered'), findsWidgets);
    });

    testWidgets('shows Cancel Order button for active orders', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Order'), findsOneWidget);
    });

    testWidgets('hides Cancel Order button for delivered orders', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.deliveredOrder));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Order'), findsNothing);
    });

    testWidgets('cancel button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel Order'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to cancel this order?'), findsOneWidget);
    });

    testWidgets('shows order subtotal and delivery fee', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Delivery fee'), findsWidgets);
      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('shows loading state when no order loaded', (tester) async {
      mockOrderRepo.watchOrderResult = null;

      await tester.pumpWidget(
        TestApp(
          orderRepository: mockOrderRepo,
          child: const OrderDetailScreen(orderId: 'order-1'),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('has an AppBar with title', (tester) async {
      await tester.pumpWidget(buildScreen(tester, order: TestData.order));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
    });
  });
}

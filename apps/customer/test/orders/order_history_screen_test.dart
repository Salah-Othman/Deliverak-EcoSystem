import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:providers/providers.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../fixtures/test_data.dart';
import 'package:customer/features/orders/presentation/screens/order_history_screen.dart';
import 'package:customer/features/orders/presentation/screens/order_detail_screen.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockOrderRepository mockOrderRepo;

  setUp(() {
    mockAuthRepo = TestHelpers.createMockAuthRepository(
      currentUser: TestData.customer,
    );
    mockOrderRepo = MockOrderRepository();
  });

  group('OrderHistoryScreen', () {
    Widget buildScreen() {
      final authCubit = AuthCubit(authRepository: mockAuthRepo)
        ..emit(Authenticated(TestData.customer));

      return TestApp(
        authCubit: authCubit,
        orderRepository: mockOrderRepo,
        child: const OrderHistoryScreen(),
      );
    }

    testWidgets('shows empty state when no orders', (tester) async {
      mockOrderRepo.watchOrdersResult = [];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('Your order history will appear here'), findsOneWidget);
    });

    testWidgets('shows empty state icon', (tester) async {
      mockOrderRepo.watchOrdersResult = [];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('displays order cards when orders exist', (tester) async {
      mockOrderRepo.watchOrdersResult = [TestData.order];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Order #'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('displays order status chip', (tester) async {
      mockOrderRepo.watchOrdersResult = [TestData.order];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('tapping order navigates to OrderDetailScreen', (tester) async {
      mockOrderRepo.watchOrdersResult = [TestData.order];
      mockOrderRepo.watchOrderResult = TestData.order;

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Order #'));
      await tester.pumpAndSettle();

      expect(find.byType(OrderDetailScreen), findsOneWidget);
    });

    testWidgets('shows delivered order with green status', (tester) async {
      mockOrderRepo.watchOrdersResult = [TestData.deliveredOrder];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('displays item count', (tester) async {
      mockOrderRepo.watchOrdersResult = [TestData.order];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('item'), findsWidgets);
    });
  });
}

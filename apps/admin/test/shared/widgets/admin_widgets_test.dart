import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin/shared/widgets/admin_widgets.dart';
import 'package:core/core.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('OrderStatusChip', () {
    testWidgets('renders pending status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const OrderStatusChip(status: OrderStatus.pending)),
      );
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders delivered status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const OrderStatusChip(status: OrderStatus.delivered)),
      );
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('renders cancelled status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const OrderStatusChip(status: OrderStatus.cancelled)),
      );
      expect(find.text('Cancelled'), findsOneWidget);
    });
  });

  group('UserRoleChip', () {
    testWidgets('renders customer role', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const UserRoleChip(role: UserRole.customer)),
      );
      expect(find.text('Customer'), findsOneWidget);
    });

    testWidgets('renders admin role', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const UserRoleChip(role: UserRole.admin)),
      );
      expect(find.text('Admin'), findsOneWidget);
    });
  });

  group('OpenStatusChip', () {
    testWidgets('renders Open when isOpen is true', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const OpenStatusChip(isOpen: true)),
      );
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('renders Closed when isOpen is false', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const OpenStatusChip(isOpen: false)),
      );
      expect(find.text('Closed'), findsOneWidget);
    });
  });

  group('DetailRow', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const DetailRow(label: 'Name', value: 'Test Value')),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Test Value'), findsOneWidget);
    });
  });
}

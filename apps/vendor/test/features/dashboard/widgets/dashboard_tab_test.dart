import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:core/core.dart';
import 'package:providers/providers.dart';
import 'package:vendor/features/dashboard/presentation/screens/dashboard_tab.dart';

void main() {
  late MockVendorProfileCubit mockProfileCubit;
  late MockVendorOrderCubit mockOrderCubit;

  setUp(() {
    mockProfileCubit = MockVendorProfileCubit();
    mockOrderCubit = MockVendorOrderCubit();
    when(() => mockProfileCubit.state).thenReturn(VendorProfileInitial());
    when(() => mockProfileCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockOrderCubit.state).thenReturn(VendorOrderInitial());
    when(() => mockOrderCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildDashboardTab() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<VendorProfileCubit>.value(value: mockProfileCubit),
          BlocProvider<VendorOrderCubit>.value(value: mockOrderCubit),
        ],
        child: const Scaffold(body: DashboardTab()),
      ),
    );
  }

  group('DashboardTab', () {
    testWidgets('renders store name when profile loaded', (tester) async {
      when(() => mockProfileCubit.state).thenReturn(
        VendorProfileLoaded(
          VendorModel(
            vendorId: 'v1',
            name: 'Pizza Palace',
            description: 'Best pizza',
            image: '',
            category: DeliveryType.food,
            lat: 0,
            lng: 0,
            address: '123 Pizza St',
            rating: 4.5,
            totalOrders: 100,
            isOpen: true,
            ownerId: 'owner-1',
            createdAt: DateTime(2024),
          ),
        ),
      );
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('Pizza Palace'), findsOneWidget);
    });

    testWidgets('shows default store name when profile not loaded', (tester) async {
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('Your Store'), findsOneWidget);
    });

    testWidgets('renders stat cards for pending and active', (tester) async {
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));
    });

    testWidgets('shows pending count when orders loaded', (tester) async {
      when(() => mockOrderCubit.state).thenReturn(
        VendorOrdersLoaded(
          pendingOrders: List.generate(3, (i) => _order('o$i', OrderStatus.pending)),
          activeOrders: List.generate(2, (i) => _order('a$i', OrderStatus.accepted)),
          completedOrders: [],
        ),
      );
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders open/close toggle when profile loaded', (tester) async {
      when(() => mockProfileCubit.state).thenReturn(
        VendorProfileLoaded(
          VendorModel(
            vendorId: 'v1',
            name: 'Test',
            description: '',
            image: '',
            category: DeliveryType.food,
            lat: 0,
            lng: 0,
            address: '',
            rating: 0,
            totalOrders: 0,
            isOpen: true,
            ownerId: 'owner-1',
            createdAt: DateTime(2024),
          ),
        ),
      );
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('Store is Open'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('shows empty state when no orders', (tester) async {
      await tester.pumpWidget(buildDashboardTab());
      expect(find.text('No orders yet'), findsOneWidget);
    });
  });
}

OrderModel _order(String id, OrderStatus status) => OrderModel(
      orderId: id,
      customerId: 'c1',
      vendorId: 'v1',
      items: [OrderItem(productId: 'p1', name: 'Item', quantity: 1, price: 5.0)],
      totalAmount: 5.0,
      deliveryFee: 2.99,
      status: status,
      deliveryAddress: DeliveryAddress(lat: 0, lng: 0, address: '', name: '', phone: ''),
      paymentMethod: 'cash',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

class MockVendorProfileCubit extends Mock implements VendorProfileCubit {}
class MockVendorOrderCubit extends Mock implements VendorOrderCubit {}

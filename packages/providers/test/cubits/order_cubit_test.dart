import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockOrderRepository mockOrderRepository;
  late OrderCubit cubit;

  setUpAll(() {
    registerFallbackValue(OrderStatus.pending);
    registerFallbackValue(OrderModelFixture.createDeliveryAddress());
  });

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    cubit = OrderCubit(orderRepository: mockOrderRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('OrderCubit', () {
    test('initial state is OrderInitial', () {
      expect(cubit.state, isA<OrderInitial>());
    });

    blocTest<OrderCubit, OrderState>(
      'emits [OrderLoading, OrderCreated] on createOrder success',
      build: () {
        final order = OrderModelFixture.create();
        when(() => mockOrderRepository.createOrder(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              items: any(named: 'items'),
              totalAmount: any(named: 'totalAmount'),
              deliveryFee: any(named: 'deliveryFee'),
              deliveryAddress: any(named: 'deliveryAddress'),
            )).thenAnswer((_) async => order);
        return cubit;
      },
      act: (cubit) => cubit.createOrder(
        customerId: 'c1',
        vendorId: 'v1',
        items: [OrderModelFixture.createOrderItem()],
        totalAmount: 22.97,
        deliveryFee: 2.99,
        deliveryAddress: OrderModelFixture.createDeliveryAddress(),
      ),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderCreated>(),
      ],
    );

    blocTest<OrderCubit, OrderState>(
      'emits [OrderLoading, OrderError] on createOrder failure',
      build: () {
        when(() => mockOrderRepository.createOrder(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              items: any(named: 'items'),
              totalAmount: any(named: 'totalAmount'),
              deliveryFee: any(named: 'deliveryFee'),
              deliveryAddress: any(named: 'deliveryAddress'),
            )).thenThrow(Exception('failed'));
        return cubit;
      },
      act: (cubit) => cubit.createOrder(
        customerId: 'c1',
        vendorId: 'v1',
        items: [OrderModelFixture.createOrderItem()],
        totalAmount: 22.97,
        deliveryFee: 2.99,
        deliveryAddress: OrderModelFixture.createDeliveryAddress(),
      ),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderError>(),
      ],
    );

    blocTest<OrderCubit, OrderState>(
      'emits [OrderLoading, OrdersLoaded] on loadOrders',
      build: () {
        when(() => mockOrderRepository.getOrdersPaginated(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              driverId: any(named: 'driverId'),
              status: any(named: 'status'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<OrderModel>(
              items: [OrderModelFixture.create()],
              hasMore: false,
            ));
        return cubit;
      },
      act: (cubit) => cubit.loadOrders(customerId: 'c1'),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrdersLoaded>(),
      ],
    );

    blocTest<OrderCubit, OrderState>(
      'cancelOrder emits [OrderLoading]',
      build: () {
        when(() => mockOrderRepository.updateOrderStatus(
              any(),
              any(),
            )).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.cancelOrder('order-1'),
      expect: () => [isA<OrderLoading>()],
    );

    blocTest<OrderCubit, OrderState>(
      'loadMore appends orders when more available',
      build: () {
        when(() => mockOrderRepository.getOrdersPaginated(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              driverId: any(named: 'driverId'),
              status: any(named: 'status'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<OrderModel>(
              items: [OrderModelFixture.create(orderId: 'order-2')],
              hasMore: true,
            ));
        return cubit;
      },
      seed: () => OrdersLoaded(
        orders: [OrderModelFixture.create(orderId: 'order-1')],
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<OrdersLoaded>(),
        isA<OrdersLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as OrdersLoaded;
        expect(state.orders.length, 2);
        expect(state.hasMore, true);
      },
    );

    blocTest<OrderCubit, OrderState>(
      'loadMore does nothing when hasMore is false',
      build: () => cubit,
      seed: () => OrdersLoaded(
        orders: [OrderModelFixture.create()],
        hasMore: false,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    test('close cancels both subscriptions', () async {
      final ordersController = StreamController<List<OrderModel>>();
      final orderController = StreamController<OrderModel?>();

      when(() => mockOrderRepository.watchOrders(
            customerId: any(named: 'customerId'),
            vendorId: any(named: 'vendorId'),
            driverId: any(named: 'driverId'),
            status: any(named: 'status'),
          )).thenAnswer((_) => ordersController.stream);

      when(() => mockOrderRepository.watchOrder(any()))
          .thenAnswer((_) => orderController.stream);

      cubit.watchOrders(customerId: 'c1');
      cubit.watchOrder('order-1');

      await cubit.close();

      expect(ordersController.hasListener, false);
      expect(orderController.hasListener, false);

      await ordersController.close();
      await orderController.close();
    });
  });
}

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
  late MockDriverRepository mockDriverRepository;
  late DriverOrderCubit cubit;

  setUpAll(() {
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockDriverRepository = MockDriverRepository();
    cubit = DriverOrderCubit(
      orderRepository: mockOrderRepository,
      driverRepository: mockDriverRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DriverOrderCubit', () {
    test('initial state is DriverOrderInitial', () {
      expect(cubit.state, isA<DriverOrderInitial>());
    });

    group('watchAvailableOrders', () {
      test('subscribes to order stream filtered by accepted + no driver', () async {
        final controller = StreamController<List<OrderModel>>();

        when(() => mockOrderRepository.watchOrders(
              status: OrderStatus.accepted,
            )).thenAnswer((_) => controller.stream);

        cubit.watchAvailableOrders();

        controller.add([
          OrderModelFixture.create(
            status: OrderStatus.accepted,
            driverId: null,
          ),
          OrderModelFixture.create(
            orderId: 'order-2',
            status: OrderStatus.accepted,
            driverId: 'other-driver',
          ),
        ]);

        await Future.delayed(Duration.zero);

        final state = cubit.state;
        expect(state, isA<AvailableOrdersLoaded>());
        if (state is AvailableOrdersLoaded) {
          expect(state.orders.length, 1);
          expect(state.orders[0].orderId, 'order-123');
        }

        await controller.close();
      });

      test('emits DriverOrderError on stream error', () async {
        final controller = StreamController<List<OrderModel>>();

        when(() => mockOrderRepository.watchOrders(
              status: OrderStatus.accepted,
            )).thenAnswer((_) => controller.stream);

        cubit.watchAvailableOrders();

        controller.addError(Exception('Firestore error'));

        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<DriverOrderError>());

        await controller.close();
      });
    });

    group('watchActiveOrder', () {
      test('subscribes to orders filtered by active status for driver', () async {
        final controller = StreamController<List<OrderModel>>();

        when(() => mockOrderRepository.watchOrders(driverId: 'driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchActiveOrder('driver-1');

        controller.add([
          OrderModelFixture.create(
            status: OrderStatus.pickedUp,
            driverId: 'driver-1',
          ),
          OrderModelFixture.create(
            orderId: 'order-old',
            status: OrderStatus.delivered,
            driverId: 'driver-1',
          ),
        ]);

        await Future.delayed(Duration.zero);

        final state = cubit.state;
        expect(state, isA<ActiveOrderLoaded>());
        if (state is ActiveOrderLoaded) {
          expect(state.order.status, OrderStatus.pickedUp);
        }

        await controller.close();
      });

      test('does not emit when all orders are inactive', () async {
        final controller = StreamController<List<OrderModel>>();

        when(() => mockOrderRepository.watchOrders(driverId: 'driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchActiveOrder('driver-1');

        controller.add([
          OrderModelFixture.create(
            status: OrderStatus.delivered,
            driverId: 'driver-1',
          ),
        ]);

        await Future.delayed(Duration.zero);

        // State should still be initial (no active orders)
        expect(cubit.state, isA<DriverOrderInitial>());

        await controller.close();
      });
    });

    group('acceptOrder', () {
      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.assignDriver('order-1', 'driver-1'))
              .thenAnswer((_) async {});
          when(() => mockOrderRepository.updateOrderStatus(
                'order-1',
                OrderStatus.pickedUp,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.acceptOrder('order-1', 'driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderActionSuccess>(),
        ],
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderError] on failure',
        build: () {
          when(() => mockOrderRepository.assignDriver(any(), any()))
              .thenThrow(Exception('Failed to assign'));
          return cubit;
        },
        act: (cubit) => cubit.acceptOrder('order-1', 'driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderError>(),
        ],
      );
    });

    group('startDelivery', () {
      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                'order-1',
                OrderStatus.inTransit,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.startDelivery('order-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderActionSuccess>(),
        ],
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderError] on failure',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(any(), any()))
              .thenThrow(Exception('Failed to update'));
          return cubit;
        },
        act: (cubit) => cubit.startDelivery('order-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderError>(),
        ],
      );
    });

    group('completeDelivery', () {
      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                'order-1',
                OrderStatus.delivered,
              )).thenAnswer((_) async {});
          when(() => mockDriverRepository.getDriver('driver-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.completeDelivery('order-1', 'driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderActionSuccess>(),
        ],
        verify: (_) {
          verify(() => mockOrderRepository.updateOrderStatus(
                'order-1',
                OrderStatus.delivered,
              )).called(1);
          verify(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
              .called(1);
        },
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'sets driver online even when driver model is null',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                'order-1',
                OrderStatus.delivered,
              )).thenAnswer((_) async {});
          when(() => mockDriverRepository.getDriver('driver-1'))
              .thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.completeDelivery('order-1', 'driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderActionSuccess>(),
        ],
        verify: (_) {
          verifyNever(() => mockDriverRepository.updateOnlineStatus(any(), any()));
        },
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderError] on failure',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(any(), any()))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.completeDelivery('order-1', 'driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderError>(),
        ],
      );
    });

    group('loadDeliveryHistory', () {
      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrdersLoaded] with delivered orders',
        build: () {
          when(() => mockOrderRepository.getOrders(driverId: 'driver-1'))
              .thenAnswer((_) async => [
                    OrderModelFixture.create(
                      status: OrderStatus.delivered,
                      deliveryFee: 3.50,
                    ),
                    OrderModelFixture.create(
                      orderId: 'order-2',
                      status: OrderStatus.delivered,
                      deliveryFee: 4.00,
                    ),
                    OrderModelFixture.create(
                      orderId: 'order-3',
                      status: OrderStatus.inTransit,
                      deliveryFee: 2.50,
                    ),
                  ]);
          return cubit;
        },
        act: (cubit) => cubit.loadDeliveryHistory('driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          predicate<DriverOrdersLoaded>((state) {
            return state.orders.length == 2 &&
                state.totalEarnings == 7.50;
          }),
        ],
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrdersLoaded] with empty list when no deliveries',
        build: () {
          when(() => mockOrderRepository.getOrders(driverId: 'driver-1'))
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadDeliveryHistory('driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          predicate<DriverOrdersLoaded>((state) {
            return state.orders.isEmpty && state.totalEarnings == 0;
          }),
        ],
      );

      blocTest<DriverOrderCubit, DriverOrderState>(
        'emits [DriverOrderLoading, DriverOrderError] on failure',
        build: () {
          when(() => mockOrderRepository.getOrders(driverId: 'driver-1'))
              .thenThrow(Exception('Firestore error'));
          return cubit;
        },
        act: (cubit) => cubit.loadDeliveryHistory('driver-1'),
        expect: () => [
          isA<DriverOrderLoading>(),
          isA<DriverOrderError>(),
        ],
      );
    });

    test('close cancels both subscriptions', () async {
      final availableController = StreamController<List<OrderModel>>();
      final activeController = StreamController<List<OrderModel>>();

      when(() => mockOrderRepository.watchOrders(status: OrderStatus.accepted))
          .thenAnswer((_) => availableController.stream);
      when(() => mockOrderRepository.watchOrders(driverId: 'driver-1'))
          .thenAnswer((_) => activeController.stream);

      cubit.watchAvailableOrders();
      cubit.watchActiveOrder('driver-1');

      await cubit.close();

      expect(availableController.hasListener, false);
      expect(activeController.hasListener, false);

      await availableController.close();
      await activeController.close();
    });
  });
}

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
  late VendorOrderCubit cubit;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    cubit = VendorOrderCubit(orderRepository: mockOrderRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('VendorOrderCubit', () {
    test('initial state is VendorOrderInitial', () {
      expect(cubit.state, isA<VendorOrderInitial>());
    });

    group('watchAllOrders', () {
      late StreamController<List<OrderModel>> ordersController;

      setUp(() {
        ordersController = StreamController<List<OrderModel>>();
        when(() => mockOrderRepository.watchOrders(
              vendorId: any(named: 'vendorId'),
            )).thenAnswer((_) => ordersController.stream);
      });

      tearDown(() {
        ordersController.close();
      });

      blocTest<VendorOrderCubit, VendorOrderState>(
        'categorizes orders into pending, active, and completed',
        build: () => cubit,
        act: (cubit) {
          cubit.watchAllOrders('vendor-1');
          ordersController.add([
            OrderModelFixture.create(
                orderId: 'o1', status: OrderStatus.pending),
            OrderModelFixture.create(
                orderId: 'o2', status: OrderStatus.accepted),
            OrderModelFixture.create(
                orderId: 'o3', status: OrderStatus.preparing),
            OrderModelFixture.create(
                orderId: 'o4', status: OrderStatus.pickedUp),
            OrderModelFixture.create(
                orderId: 'o5', status: OrderStatus.inTransit),
            OrderModelFixture.create(
                orderId: 'o6', status: OrderStatus.delivered),
            OrderModelFixture.create(
                orderId: 'o7', status: OrderStatus.cancelled),
          ]);
        },
        expect: () => [
          isA<VendorOrdersLoaded>().having(
            (s) => s.pendingOrders.length,
            'pending count',
            1,
          ),
        ],
        verify: (cubit) {
          final loaded = cubit.state as VendorOrdersLoaded;
          expect(loaded.pendingOrders.length, 1);
          expect(loaded.activeOrders.length, 4);
          expect(loaded.completedOrders.length, 2);
          expect(loaded.pendingOrders.first.orderId, 'o1');
          expect(loaded.activeOrders.map((o) => o.orderId).toList(),
              ['o2', 'o3', 'o4', 'o5']);
          expect(loaded.completedOrders.map((o) => o.orderId).toList(),
              ['o6', 'o7']);
        },
      );

      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits error on stream error',
        build: () => cubit,
        act: (cubit) {
          cubit.watchAllOrders('vendor-1');
          ordersController.addError(Exception('Firestore error'));
        },
        expect: () => [isA<VendorOrderError>()],
      );
    });

    group('watchOrder', () {
      late StreamController<OrderModel?> orderController;

      setUp(() {
        orderController = StreamController<OrderModel?>();
        when(() => mockOrderRepository.watchOrder(any()))
            .thenAnswer((_) => orderController.stream);
      });

      tearDown(() {
        orderController.close();
      });

      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits VendorOrderDetailLoaded when order received',
        build: () => cubit,
        act: (cubit) {
          cubit.watchOrder('order-1');
          orderController.add(OrderModelFixture.create(orderId: 'order-1'));
        },
        expect: () => [isA<VendorOrderDetailLoaded>()],
        verify: (cubit) {
          final loaded = cubit.state as VendorOrderDetailLoaded;
          expect(loaded.order.orderId, 'order-1');
        },
      );

      blocTest<VendorOrderCubit, VendorOrderState>(
        'does not emit when order is null',
        build: () => cubit,
        act: (cubit) {
          cubit.watchOrder('order-1');
          orderController.add(null);
        },
        expect: () => <VendorOrderState>[],
      );

      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits error on stream error',
        build: () => cubit,
        act: (cubit) {
          cubit.watchOrder('order-1');
          orderController.addError(Exception('Stream error'));
        },
        expect: () => [isA<VendorOrderError>()],
      );
    });

    group('acceptOrder', () {
      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                any(),
                OrderStatus.accepted,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.acceptOrder('order-1'),
        expect: () => [
          isA<VendorOrderLoading>(),
          isA<VendorOrderActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorOrderActionSuccess;
          expect(success.message, contains('accepted'));
        },
      );

      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits [Loading, Error] on failure',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                any(),
                OrderStatus.accepted,
              )).thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.acceptOrder('order-1'),
        expect: () => [
          isA<VendorOrderLoading>(),
          isA<VendorOrderError>(),
        ],
      );
    });

    group('rejectOrder', () {
      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                any(),
                OrderStatus.cancelled,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.rejectOrder('order-1'),
        expect: () => [
          isA<VendorOrderLoading>(),
          isA<VendorOrderActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorOrderActionSuccess;
          expect(success.message, contains('rejected'));
        },
      );
    });

    group('markPreparing', () {
      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                any(),
                OrderStatus.preparing,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.markPreparing('order-1'),
        expect: () => [
          isA<VendorOrderLoading>(),
          isA<VendorOrderActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorOrderActionSuccess;
          expect(success.message, contains('prepared'));
        },
      );
    });

    group('markReady', () {
      blocTest<VendorOrderCubit, VendorOrderState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockOrderRepository.updateOrderStatus(
                any(),
                OrderStatus.pickedUp,
              )).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.markReady('order-1'),
        expect: () => [
          isA<VendorOrderLoading>(),
          isA<VendorOrderActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorOrderActionSuccess;
          expect(success.message, contains('ready'));
        },
      );
    });

    group('unwatchOrder', () {
      test('cancels order subscription', () async {
        final controller = StreamController<OrderModel?>();
        when(() => mockOrderRepository.watchOrder(any()))
            .thenAnswer((_) => controller.stream);

        cubit.watchOrder('order-1');
        cubit.unwatchOrder();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });

    group('close', () {
      test('cancels all subscriptions', () async {
        final ordersController = StreamController<List<OrderModel>>();
        final orderController = StreamController<OrderModel?>();

        when(() => mockOrderRepository.watchOrders(
              vendorId: any(named: 'vendorId'),
            )).thenAnswer((_) => ordersController.stream);
        when(() => mockOrderRepository.watchOrder(any()))
            .thenAnswer((_) => orderController.stream);

        cubit.watchAllOrders('vendor-1');
        cubit.watchOrder('order-1');

        await cubit.close();

        expect(ordersController.hasListener, isFalse);
        expect(orderController.hasListener, isFalse);

        await ordersController.close();
        await orderController.close();
      });
    });
  });
}

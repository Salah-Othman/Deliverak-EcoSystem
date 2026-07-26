import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockVendorRepository mockVendorRepository;
  late MockOrderRepository mockOrderRepository;
  late MockDriverRepository mockDriverRepository;
  late AdminCubit cubit;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockVendorRepository = MockVendorRepository();
    mockOrderRepository = MockOrderRepository();
    mockDriverRepository = MockDriverRepository();
    cubit = AdminCubit(
      userRepository: mockUserRepository,
      vendorRepository: mockVendorRepository,
      orderRepository: mockOrderRepository,
      driverRepository: mockDriverRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  setUpAll(() {
    registerFallbackValue(OrderStatus.pending);
  });

  group('AdminCubit', () {
    test('initial state is AdminInitial', () {
      expect(cubit.state, isA<AdminInitial>());
    });

    blocTest<AdminCubit, AdminState>(
      'emits [AdminLoading, AdminDashboardLoaded] on loadDashboard success',
      build: () {
        when(() => mockUserRepository.getUsersCount())
            .thenAnswer((_) async => 42);
        when(() => mockVendorRepository.getVendors(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [
              VendorModelFixture.create(vendorId: 'v1'),
              VendorModelFixture.create(vendorId: 'v2'),
            ]);
        when(() => mockOrderRepository.getOrders(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              driverId: any(named: 'driverId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => [
              OrderModelFixture.create(
                orderId: 'order-1',
                totalAmount: 25.50,
                status: OrderStatus.pending,
              ),
              OrderModelFixture.create(
                orderId: 'order-2',
                totalAmount: 15.00,
                status: OrderStatus.delivered,
              ),
            ]);
        when(() => mockDriverRepository.getAvailableDrivers())
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminDashboardLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as AdminDashboardLoaded;
        expect(loaded.totalUsers, 42);
        expect(loaded.totalVendors, 2);
        expect(loaded.totalOrders, 2);
        expect(loaded.totalDrivers, 0);
        expect(loaded.totalRevenue, closeTo(40.50, 0.01));
        expect(loaded.recentOrders.length, 2);
        expect(loaded.ordersByStatus[OrderStatus.pending], 1);
        expect(loaded.ordersByStatus[OrderStatus.delivered], 1);
      },
    );

    blocTest<AdminCubit, AdminState>(
      'emits [AdminLoading, AdminError] on loadDashboard failure',
      build: () {
        when(() => mockUserRepository.getUsersCount())
            .thenThrow(Exception('Firestore error'));
        when(() => mockVendorRepository.getVendors(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => []);
        when(() => mockOrderRepository.getOrders(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              driverId: any(named: 'driverId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => []);
        when(() => mockDriverRepository.getAvailableDrivers())
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<AdminLoading>(),
        isA<AdminError>(),
      ],
    );

    blocTest<AdminCubit, AdminState>(
      'truncates recent orders to 10 when more exist',
      build: () {
        when(() => mockUserRepository.getUsersCount())
            .thenAnswer((_) async => 1);
        when(() => mockVendorRepository.getVendors(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => []);
        when(() => mockOrderRepository.getOrders(
              customerId: any(named: 'customerId'),
              vendorId: any(named: 'vendorId'),
              driverId: any(named: 'driverId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => List.generate(
                  15,
                  (i) => OrderModelFixture.create(
                    orderId: 'order-$i',
                    totalAmount: 10.0,
                  ),
                ));
        when(() => mockDriverRepository.getAvailableDrivers())
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final loaded = cubit.state as AdminDashboardLoaded;
        expect(loaded.totalOrders, 15);
        expect(loaded.recentOrders.length, 10);
      },
    );
  });
}

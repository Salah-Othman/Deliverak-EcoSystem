import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:providers/providers.dart';

import 'mocks.dart';
import '../fixtures/test_data.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final AuthCubit? authCubit;
  final VendorCubit? vendorCubit;
  final SearchCubit? searchCubit;
  final ProductCubit? productCubit;
  final CartCubit? cartCubit;
  final OrderCubit? orderCubit;
  final NotificationCubit? notificationCubit;
  final MockAuthRepository? authRepository;
  final MockVendorRepository? vendorRepository;
  final MockProductRepository? productRepository;
  final MockOrderRepository? orderRepository;
  final MockNotificationRepository? notificationRepository;

  const TestApp({
    super.key,
    required this.child,
    this.authCubit,
    this.vendorCubit,
    this.searchCubit,
    this.productCubit,
    this.cartCubit,
    this.orderCubit,
    this.notificationCubit,
    this.authRepository,
    this.vendorRepository,
    this.productRepository,
    this.orderRepository,
    this.notificationRepository,
  });

  @override
  Widget build(BuildContext context) {
    final mockAuthRepo = authRepository ?? MockAuthRepository();
    final mockVendorRepo = vendorRepository ?? MockVendorRepository();
    final mockProductRepo = productRepository ?? MockProductRepository();
    final mockOrderRepo = orderRepository ?? MockOrderRepository();
    final mockNotifRepo = notificationRepository ?? MockNotificationRepository();

    final auth = authCubit ?? AuthCubit(authRepository: mockAuthRepo);
    final vendor = vendorCubit ?? VendorCubit(vendorRepository: mockVendorRepo);
    final search = searchCubit ?? SearchCubit(vendorRepository: mockVendorRepo);
    final product = productCubit ?? ProductCubit(productRepository: mockProductRepo);
    final cart = cartCubit ?? CartCubit();
    final order = orderCubit ?? OrderCubit(orderRepository: mockOrderRepo);
    final notif = notificationCubit ?? NotificationCubit(notificationRepository: mockNotifRepo);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>.value(value: mockAuthRepo),
        RepositoryProvider<IVendorRepository>.value(value: mockVendorRepo),
        RepositoryProvider<IProductRepository>.value(value: mockProductRepo),
        RepositoryProvider<IOrderRepository>.value(value: mockOrderRepo),
        RepositoryProvider<INotificationRepository>.value(value: mockNotifRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<VendorCubit>.value(value: vendor),
          BlocProvider<SearchCubit>.value(value: search),
          BlocProvider<ProductCubit>.value(value: product),
          BlocProvider<CartCubit>.value(value: cart),
          BlocProvider<OrderCubit>.value(value: order),
          BlocProvider<NotificationCubit>.value(value: notif),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: child,
        ),
      ),
    );
  }
}

class TestHelpers {
  TestHelpers._();

  static MockAuthRepository createMockAuthRepository({
    User? authStateChangesUser,
    UserModel? currentUser,
  }) {
    final repo = MockAuthRepository();
    when(() => repo.authStateChanges)
        .thenAnswer((_) => Stream.value(authStateChangesUser));
    when(() => repo.getCurrentUser())
        .thenAnswer((_) async => currentUser);
    when(() => repo.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          onCompleted: any(named: 'onCompleted'),
          onFailed: any(named: 'onFailed'),
          onCodeSent: any(named: 'onCodeSent'),
          onCodeTimeout: any(named: 'onCodeTimeout'),
        )).thenAnswer((_) async {});
    when(() => repo.signOut()).thenAnswer((_) async {});
    return repo;
  }

  static MockVendorRepository createMockVendorRepository({
    List<VendorModel>? vendors,
  }) {
    final repo = MockVendorRepository();
    when(() => repo.getVendors(
          category: any(named: 'category'),
          isOpen: any(named: 'isOpen'),
        )).thenAnswer((_) async => vendors ?? [TestData.vendor]);
    when(() => repo.searchVendors(any())).thenAnswer(
      (_) async => vendors ?? [TestData.vendor],
    );
    return repo;
  }

  static MockProductRepository createMockProductRepository({
    List<ProductModel>? products,
  }) {
    final repo = MockProductRepository();
    when(() => repo.getProducts(vendorId: any(named: 'vendorId')))
        .thenAnswer((_) async => products ?? [TestData.product]);
    return repo;
  }

  static MockNotificationRepository createMockNotificationRepository() {
    return MockNotificationRepository();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_services.dart';

class TestAdminApp extends StatelessWidget {
  final FakeAuthService authService;
  final FakeFirestoreService firestoreService;
  final FakeSecureStorageService secureStorage;
  final FakeCacheService cacheService;

  const TestAdminApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.secureStorage,
    required this.cacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: authService),
        RepositoryProvider<IFirestoreService>.value(value: firestoreService),
        RepositoryProvider<ISecureStorageService>.value(value: secureStorage),
        RepositoryProvider<ICacheService>.value(value: cacheService),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            authService: authService,
            firestoreService: firestoreService,
            secureStorage: secureStorage,
            cacheService: cacheService,
          ),
        ),
        RepositoryProvider<IUserRepository>(
          create: (_) => UserRepository(firestoreService: firestoreService),
        ),
        RepositoryProvider<IVendorRepository>(
          create: (_) => VendorRepository(
            firestoreService: firestoreService,
            cacheService: cacheService,
          ),
        ),
        RepositoryProvider<IProductRepository>(
          create: (_) => ProductRepository(
            firestoreService: firestoreService,
            cacheService: cacheService,
          ),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (_) => OrderRepository(
            firestoreService: firestoreService,
            cacheService: cacheService,
          ),
        ),
        RepositoryProvider<IDriverRepository>(
          create: (_) => DriverRepository(firestoreService: firestoreService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AdminAuthCubit>(
            create: (context) => AdminAuthCubit(
              authRepository: context.read<IAuthRepository>(),
            )..initAuthListener(),
          ),
          BlocProvider<AdminCubit>(
            create: (context) => AdminCubit(
              userRepository: context.read<IUserRepository>(),
              vendorRepository: context.read<IVendorRepository>(),
              orderRepository: context.read<IOrderRepository>(),
              driverRepository: context.read<IDriverRepository>(),
            ),
          ),
          BlocProvider<AdminUserCubit>(
            create: (context) => AdminUserCubit(
              userRepository: context.read<IUserRepository>(),
            ),
          ),
          BlocProvider<VendorCubit>(
            create: (context) => VendorCubit(
              vendorRepository: context.read<IVendorRepository>(),
            ),
          ),
          BlocProvider<OrderCubit>(
            create: (context) => OrderCubit(
              orderRepository: context.read<IOrderRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Deliverak Admin Test',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const _TestAdminRouter(),
        ),
      ),
    );
  }
}

class _TestAdminRouter extends StatelessWidget {
  const _TestAdminRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAuthCubit, AdminAuthState>(
      builder: (context, state) {
        if (state is AdminAuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AdminAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Admin Dashboard')),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Admin Login')),
        );
      },
    );
  }
}

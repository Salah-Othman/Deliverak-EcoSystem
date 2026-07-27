import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_services.dart';

class TestVendorApp extends StatelessWidget {
  final FakeAuthService authService;
  final FakeFirestoreService firestoreService;
  final FakeNotificationService notificationService;
  final FakeStorageService storageService;
  final FakeSecureStorageService secureStorage;
  final FakeCacheService cacheService;
  final FakeLocalNotificationService localNotificationService;

  const TestVendorApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.notificationService,
    required this.storageService,
    required this.secureStorage,
    required this.cacheService,
    required this.localNotificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: authService),
        RepositoryProvider<IFirestoreService>.value(value: firestoreService),
        RepositoryProvider<INotificationService>.value(value: notificationService),
        RepositoryProvider<IStorageService>.value(value: storageService),
        RepositoryProvider<ISecureStorageService>.value(value: secureStorage),
        RepositoryProvider<ICacheService>.value(value: cacheService),
        RepositoryProvider<ILocalNotificationService>.value(value: localNotificationService),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            authService: authService,
            firestoreService: firestoreService,
            secureStorage: secureStorage,
            cacheService: cacheService,
            notificationService: notificationService,
          ),
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
        RepositoryProvider<INotificationRepository>(
          create: (_) => NotificationRepository(
            firestoreService: firestoreService,
            cacheService: cacheService,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<IAuthRepository>(),
            )..initAuthListener(),
          ),
          BlocProvider<VendorOrderCubit>(
            create: (context) => VendorOrderCubit(
              orderRepository: context.read<IOrderRepository>(),
            ),
          ),
          BlocProvider<VendorProductCubit>(
            create: (context) => VendorProductCubit(
              productRepository: context.read<IProductRepository>(),
              storageService: context.read<IStorageService>(),
            ),
          ),
          BlocProvider<VendorProfileCubit>(
            create: (context) => VendorProfileCubit(
              vendorRepository: context.read<IVendorRepository>(),
              storageService: context.read<IStorageService>(),
            ),
          ),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              notificationRepository: context.read<INotificationRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Deliverak Vendor Test',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const _TestVendorRouter(),
        ),
      ),
    );
  }
}

class _TestVendorRouter extends StatelessWidget {
  const _TestVendorRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ProfileSetup) {
          return const Scaffold(
            body: Center(child: Text('Profile Setup')),
          );
        }
        if (state is Authenticated) {
          return const Scaffold(
            body: Center(child: Text('Vendor Home')),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Vendor Login')),
        );
      },
    );
  }
}

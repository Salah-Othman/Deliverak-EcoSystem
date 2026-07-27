import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:core/core.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_services.dart';

class TestDeliverakApp extends StatelessWidget {
  final FakeAuthService authService;
  final FakeFirestoreService firestoreService;
  final FakeNotificationService notificationService;
  final FakeStorageService storageService;
  final FakeSecureStorageService secureStorage;
  final FakeCacheService cacheService;
  final FakeLocalNotificationService localNotificationService;

  const TestDeliverakApp({
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
          create: (_) => DriverRepository(
            firestoreService: firestoreService,
          ),
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
          BlocProvider<VendorCubit>(
            create: (context) => VendorCubit(
              vendorRepository: context.read<IVendorRepository>(),
            ),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              vendorRepository: context.read<IVendorRepository>(),
            ),
          ),
          BlocProvider<ProductCubit>(
            create: (context) => ProductCubit(
              productRepository: context.read<IProductRepository>(),
            ),
          ),
          BlocProvider<CartCubit>(
            create: (_) => CartCubit(),
          ),
          BlocProvider<OrderCubit>(
            create: (context) => OrderCubit(
              orderRepository: context.read<IOrderRepository>(),
            ),
          ),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              notificationRepository: context.read<INotificationRepository>(),
            ),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (_) => ConnectivityCubit()..init(),
          ),
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(
              secureStorage: secureStorage,
            )..loadTheme(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Deliverak Test',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.flutterThemeMode,
              home: const _TestAppRouter(),
            );
          },
        ),
      ),
    );
  }
}

class _TestAppRouter extends StatelessWidget {
  const _TestAppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is PhoneSubmitted) {
          return const Scaffold(body: Center(child: Text('OTP Screen')));
        }
        if (state is ProfileSetup) {
          return const Scaffold(body: Center(child: Text('Profile Setup')));
        }
        if (state is Authenticated) {
          return const Scaffold(body: Center(child: Text('Home Screen')));
        }
        return const Scaffold(body: Center(child: Text('Login Screen')));
      },
    );
  }
}

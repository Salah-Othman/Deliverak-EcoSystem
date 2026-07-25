import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:core/core.dart';
import 'package:firebase_services/firebase_services.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final IAuthService authService = FirebaseAuthService();
  final IFirestoreService firestoreService = FirestoreService();
  final INotificationService fcmService = FCMService();

  final IStorageService cloudinaryService = CloudinaryService(
    cloudName: Env.cloudinaryCloudName,
    uploadPreset: Env.cloudinaryUploadPreset,
  );

  await fcmService.requestPermission();

  runApp(
    DeliverakApp(
      authService: authService,
      firestoreService: firestoreService,
      fcmService: fcmService,
      cloudinaryService: cloudinaryService,
    ),
  );
}

class DeliverakApp extends StatelessWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final INotificationService fcmService;
  final IStorageService cloudinaryService;

  const DeliverakApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.fcmService,
    required this.cloudinaryService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: authService),
        RepositoryProvider<IFirestoreService>.value(value: firestoreService),
        RepositoryProvider<INotificationService>.value(value: fcmService),
        RepositoryProvider<IStorageService>.value(value: cloudinaryService),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            authService: authService,
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider<IVendorRepository>(
          create: (_) => VendorRepository(firestoreService: firestoreService),
        ),
        RepositoryProvider<IProductRepository>(
          create: (_) => ProductRepository(firestoreService: firestoreService),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (_) => OrderRepository(firestoreService: firestoreService),
        ),
        RepositoryProvider<IDriverRepository>(
          create: (_) => DriverRepository(firestoreService: firestoreService),
        ),
        RepositoryProvider<INotificationRepository>(
          create: (_) => NotificationRepository(firestoreService: firestoreService),
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
        ],
        child: MaterialApp(
          title: 'Deliverak',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AppRouter(),
        ),
      ),
    );
  }
}

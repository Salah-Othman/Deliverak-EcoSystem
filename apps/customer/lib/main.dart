import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:core/core.dart';
import 'package:firebase_services/firebase_services.dart';
import 'package:cloudinary_service/cloudinary_service.dart';
import 'package:local_storage/local_storage.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';
import 'config/env.dart';
import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  final IAuthService authService = FirebaseAuthService();
  final IFirestoreService firestoreService = FirestoreService();
  final INotificationService fcmService = FCMService();
  final ISecureStorageService secureStorage = SecureStorageService();
  final ICacheService cacheService = HiveCacheService();

  await cacheService.init();
  await fcmService.requestPermission();

  final IStorageService cloudinaryService = CloudinaryService(
    cloudName: Env.cloudinaryCloudName,
    uploadPreset: Env.cloudinaryUploadPreset,
  );

  runApp(
    DeliverakApp(
      authService: authService,
      firestoreService: firestoreService,
      fcmService: fcmService,
      cloudinaryService: cloudinaryService,
      secureStorage: secureStorage,
      cacheService: cacheService,
    ),
  );
}

class DeliverakApp extends StatelessWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final INotificationService fcmService;
  final IStorageService cloudinaryService;
  final ISecureStorageService secureStorage;
  final ICacheService cacheService;

  const DeliverakApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.fcmService,
    required this.cloudinaryService,
    required this.secureStorage,
    required this.cacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: authService),
        RepositoryProvider<IFirestoreService>.value(value: firestoreService),
        RepositoryProvider<INotificationService>.value(value: fcmService),
        RepositoryProvider<IStorageService>.value(value: cloudinaryService),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:core/core.dart';
import 'package:firebase_services/firebase_services.dart';
import 'package:local_storage/local_storage.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'config/firebase_options.dart';
import 'app/admin_router.dart';

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
  final ISecureStorageService secureStorage = SecureStorageService();
  final ICacheService cacheService = HiveCacheService();

  await cacheService.init();

  runApp(
    DeliverakAdminApp(
      authService: authService,
      firestoreService: firestoreService,
      secureStorage: secureStorage,
      cacheService: cacheService,
    ),
  );
}

class DeliverakAdminApp extends StatelessWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final ISecureStorageService secureStorage;
  final ICacheService cacheService;

  const DeliverakAdminApp({
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
          create: (_) => UserRepository(
            firestoreService: firestoreService,
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
          title: 'Deliverak Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AdminRouter(),
        ),
      ),
    );
  }
}

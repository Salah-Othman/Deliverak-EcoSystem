import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:core/core.dart';
import 'package:firebase_services/firebase_services.dart';
import 'package:local_storage/local_storage.dart';
import 'package:repositories/repositories.dart';
import 'package:providers/providers.dart';
import 'package:ui_kit/ui_kit.dart';

import 'app/app.dart';
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

  runApp(
    DriverApp(
      authService: authService,
      firestoreService: firestoreService,
      fcmService: fcmService,
      secureStorage: secureStorage,
      cacheService: cacheService,
    ),
  );
}

class DriverApp extends StatelessWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final INotificationService fcmService;
  final ISecureStorageService secureStorage;
  final ICacheService cacheService;

  const DriverApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.fcmService,
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
        RepositoryProvider<IDriverRepository>(
          create: (_) => DriverRepository(
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (_) => OrderRepository(
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
          BlocProvider<DriverCubit>(
            create: (context) => DriverCubit(
              driverRepository: context.read<IDriverRepository>(),
              authRepository: context.read<IAuthRepository>(),
            ),
          ),
          BlocProvider<DriverOrderCubit>(
            create: (context) => DriverOrderCubit(
              orderRepository: context.read<IOrderRepository>(),
              driverRepository: context.read<IDriverRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Deliverak Driver',
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

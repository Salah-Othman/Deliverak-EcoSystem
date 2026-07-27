import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

final navigatorKey = GlobalKey<NavigatorState>();

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
  final ILocalNotificationService localNotificationService =
      LocalNotificationService();

  await cacheService.init();
  await fcmService.requestPermission();
  await localNotificationService.initialize(
    androidChannelId: 'deliverak_default',
    androidChannelName: 'Deliverak Notifications',
    androidChannelDescription: 'General notifications from Deliverak',
  );

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
      localNotificationService: localNotificationService,
    ),
  );
}

class DeliverakApp extends StatefulWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final INotificationService fcmService;
  final IStorageService cloudinaryService;
  final ISecureStorageService secureStorage;
  final ICacheService cacheService;
  final ILocalNotificationService localNotificationService;

  const DeliverakApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.fcmService,
    required this.cloudinaryService,
    required this.secureStorage,
    required this.cacheService,
    required this.localNotificationService,
  });

  @override
  State<DeliverakApp> createState() => _DeliverakAppState();
}

class _DeliverakAppState extends State<DeliverakApp> {
  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  @override
  void initState() {
    super.initState();
    _setupForegroundListener();
  }

  void _setupForegroundListener() {
    _foregroundSubscription =
        widget.fcmService.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      widget.localNotificationService.showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data['referenceId'],
      );
    });
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: widget.authService),
        RepositoryProvider<IFirestoreService>.value(value: widget.firestoreService),
        RepositoryProvider<INotificationService>.value(value: widget.fcmService),
        RepositoryProvider<IStorageService>.value(value: widget.cloudinaryService),
        RepositoryProvider<ISecureStorageService>.value(value: widget.secureStorage),
        RepositoryProvider<ICacheService>.value(value: widget.cacheService),
        RepositoryProvider<ILocalNotificationService>.value(value: widget.localNotificationService),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            authService: widget.authService,
            firestoreService: widget.firestoreService,
            secureStorage: widget.secureStorage,
            cacheService: widget.cacheService,
            notificationService: widget.fcmService,
          ),
        ),
        RepositoryProvider<IVendorRepository>(
          create: (_) => VendorRepository(
            firestoreService: widget.firestoreService,
            cacheService: widget.cacheService,
          ),
        ),
        RepositoryProvider<IProductRepository>(
          create: (_) => ProductRepository(
            firestoreService: widget.firestoreService,
            cacheService: widget.cacheService,
          ),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (_) => OrderRepository(
            firestoreService: widget.firestoreService,
            cacheService: widget.cacheService,
          ),
        ),
        RepositoryProvider<IDriverRepository>(
          create: (_) => DriverRepository(
            firestoreService: widget.firestoreService,
          ),
        ),
        RepositoryProvider<INotificationRepository>(
          create: (_) => NotificationRepository(
            firestoreService: widget.firestoreService,
            cacheService: widget.cacheService,
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
        ],
        child: MaterialApp(
          title: 'Deliverak',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          builder: (context, child) {
            return Column(
              children: [
                BlocBuilder<ConnectivityCubit, ConnectivityState>(
                  builder: (context, state) {
                    return OfflineBanner(
                      isOnline: state is ConnectivityOnline,
                    );
                  },
                ),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
          home: const AppRouter(),
        ),
      ),
    );
  }
}

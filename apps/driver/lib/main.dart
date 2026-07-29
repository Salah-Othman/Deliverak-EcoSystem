import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final ILocalNotificationService localNotificationService =
      LocalNotificationService();
  final IAnalyticsService analyticsService = AnalyticsService();
  final ICrashlyticsService crashlyticsService = CrashlyticsService();

  await crashlyticsService.initialize();
  await cacheService.init();
  await fcmService.requestPermission();
  await localNotificationService.initialize(
    androidChannelId: 'deliverak_driver',
    androidChannelName: 'Driver Notifications',
    androidChannelDescription: 'Order and delivery notifications',
  );

  final offlineSyncService = OfflineSyncService(
    cache: cacheService,
    crashlytics: crashlyticsService,
  );
  await offlineSyncService.initialize();

  runApp(
    DriverApp(
      authService: authService,
      firestoreService: firestoreService,
      fcmService: fcmService,
      secureStorage: secureStorage,
      cacheService: cacheService,
      localNotificationService: localNotificationService,
      analyticsService: analyticsService,
      crashlyticsService: crashlyticsService,
      offlineSyncService: offlineSyncService,
    ),
  );
}

class DriverApp extends StatefulWidget {
  final IAuthService authService;
  final IFirestoreService firestoreService;
  final INotificationService fcmService;
  final ISecureStorageService secureStorage;
  final ICacheService cacheService;
  final ILocalNotificationService localNotificationService;
  final IAnalyticsService analyticsService;
  final ICrashlyticsService crashlyticsService;
  final OfflineSyncService offlineSyncService;

  const DriverApp({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.fcmService,
    required this.secureStorage,
    required this.cacheService,
    required this.localNotificationService,
    required this.analyticsService,
    required this.crashlyticsService,
    required this.offlineSyncService,
  });

  @override
  State<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> {
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
        RepositoryProvider<ISecureStorageService>.value(value: widget.secureStorage),
        RepositoryProvider<ICacheService>.value(value: widget.cacheService),
        RepositoryProvider<ILocalNotificationService>.value(value: widget.localNotificationService),
        RepositoryProvider<IAnalyticsService>.value(value: widget.analyticsService),
        RepositoryProvider<ICrashlyticsService>.value(value: widget.crashlyticsService),
        RepositoryProvider<OfflineSyncService>.value(value: widget.offlineSyncService),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            authService: widget.authService,
            firestoreService: widget.firestoreService,
            secureStorage: widget.secureStorage,
            cacheService: widget.cacheService,
            notificationService: widget.fcmService,
          ),
        ),
        RepositoryProvider<IDriverRepository>(
          create: (_) => DriverRepository(
            firestoreService: widget.firestoreService,
          ),
        ),
        RepositoryProvider<IOrderRepository>(
          create: (_) => OrderRepository(
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

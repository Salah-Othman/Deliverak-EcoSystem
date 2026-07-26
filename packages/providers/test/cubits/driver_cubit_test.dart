import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

class MockFirebaseUser extends Mock implements User {}

void main() {
  late MockDriverRepository mockDriverRepository;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(MockFirebaseUser());
  });

  setUp(() {
    mockDriverRepository = MockDriverRepository();
    mockAuthRepository = MockAuthRepository();
  });

  DriverCubit createCubit() => DriverCubit(
        driverRepository: mockDriverRepository,
        authRepository: mockAuthRepository,
      );

  MockFirebaseUser createFakeUser({String uid = 'user-1'}) {
    final user = MockFirebaseUser();
    when(() => user.uid).thenReturn(uid);
    return user;
  }

  Future<DriverCubit> loadDriverToLoaded({
    String driverId = 'driver-1',
    String userId = 'user-1',
  }) async {
    final cubit = createCubit();
    final user = createFakeUser(uid: userId);
    when(() => mockAuthRepository.currentUser).thenReturn(user);
    when(() => mockDriverRepository.getDriverByUserId(userId))
        .thenAnswer((_) async => DriverModelFixture.create(driverId: driverId));
    await cubit.loadDriver();
    return cubit;
  }

  tearDown(() {});

  group('DriverCubit', () {
    test('initial state is DriverInitial', () {
      final cubit = createCubit();
      expect(cubit.state, isA<DriverInitial>());
      cubit.close();
    });

    group('loadDriver', () {
      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverNotRegistered] when no current user',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return createCubit();
        },
        act: (cubit) => cubit.loadDriver(),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverNotRegistered>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverNotRegistered] when driver not found',
        build: () {
          final user = createFakeUser();
          when(() => mockAuthRepository.currentUser).thenReturn(user);
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => null);
          return createCubit();
        },
        act: (cubit) => cubit.loadDriver(),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverNotRegistered>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverLoaded] when driver found',
        build: () {
          final user = createFakeUser();
          when(() => mockAuthRepository.currentUser).thenReturn(user);
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          return createCubit();
        },
        act: (cubit) => cubit.loadDriver(),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverError] on exception',
        build: () {
          final user = createFakeUser();
          when(() => mockAuthRepository.currentUser).thenReturn(user);
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenThrow(Exception('Firestore error'));
          return createCubit();
        },
        act: (cubit) => cubit.loadDriver(),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverError>(),
        ],
      );
    });

    group('registerDriver', () {
      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverError] when not authenticated',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return createCubit();
        },
        act: (cubit) => cubit.registerDriver(
          vehicleType: 'motorcycle',
          vehicleNumber: 'ABC-1234',
          licenseNumber: 'DL-9876',
        ),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverError>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverLoaded] on success',
        build: () {
          final user = createFakeUser();
          when(() => mockAuthRepository.currentUser).thenReturn(user);
          when(() => mockDriverRepository.createDriver(
                userId: 'user-1',
                vehicleType: 'motorcycle',
                vehicleNumber: 'ABC-1234',
                licenseNumber: 'DL-9876',
              )).thenAnswer((_) async => DriverModelFixture.create());
          return createCubit();
        },
        act: (cubit) => cubit.registerDriver(
          vehicleType: 'motorcycle',
          vehicleNumber: 'ABC-1234',
          licenseNumber: 'DL-9876',
        ),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverError] on failure',
        build: () {
          final user = createFakeUser();
          when(() => mockAuthRepository.currentUser).thenReturn(user);
          when(() => mockDriverRepository.createDriver(
                userId: any(named: 'userId'),
                vehicleType: any(named: 'vehicleType'),
                vehicleNumber: any(named: 'vehicleNumber'),
                licenseNumber: any(named: 'licenseNumber'),
              )).thenThrow(Exception('Failed to create'));
          return createCubit();
        },
        act: (cubit) => cubit.registerDriver(
          vehicleType: 'motorcycle',
          vehicleNumber: 'ABC-1234',
          licenseNumber: 'DL-9876',
        ),
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverError>(),
        ],
      );
    });

    group('goOnline / goOffline', () {
      test('goOnline does nothing when state is not DriverLoaded', () async {
        final cubit = createCubit();
        await cubit.goOnline();
        verifyNever(() => mockDriverRepository.updateOnlineStatus(any(), any()));
        await cubit.close();
      });

      test('goOffline does nothing when state is not DriverLoaded', () async {
        final cubit = createCubit();
        await cubit.goOffline();
        verifyNever(() => mockDriverRepository.updateOnlineStatus(any(), any()));
        await cubit.close();
      });

      test('goOnline calls repository with true', () async {
        when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
            .thenAnswer((_) async {});

        final cubit = await loadDriverToLoaded();
        await cubit.goOnline();

        verify(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
            .called(1);
        await cubit.close();
      });

      test('goOffline calls repository with false', () async {
        when(() => mockDriverRepository.updateOnlineStatus('driver-1', false))
            .thenAnswer((_) async {});

        final cubit = await loadDriverToLoaded();
        await cubit.goOffline();

        verify(
            () => mockDriverRepository.updateOnlineStatus('driver-1', false))
            .called(1);
        await cubit.close();
      });

      test('goOnline emits DriverError on failure', () async {
        when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
            .thenThrow(Exception('Network error'));

        final cubit = await loadDriverToLoaded();
        await cubit.goOnline();

        expect(cubit.state, isA<DriverError>());
        await cubit.close();
      });
    });

    group('updateLocation', () {
      test('does nothing when state is not DriverLoaded', () async {
        final cubit = createCubit();
        await cubit.updateLocation(40.0, -74.0);
        verifyNever(
            () => mockDriverRepository.updateLocation(any(), any(), any()));
        await cubit.close();
      });

      test('calls repository when state is DriverLoaded', () async {
        when(() => mockDriverRepository.updateLocation('driver-1', 40.0, -74.0))
            .thenAnswer((_) async {});

        final cubit = await loadDriverToLoaded();
        await cubit.updateLocation(40.0, -74.0);

        verify(
            () => mockDriverRepository.updateLocation('driver-1', 40.0, -74.0))
            .called(1);
        await cubit.close();
      });

      test('silently handles errors from repository', () async {
        when(() => mockDriverRepository.updateLocation(any(), any(), any()))
            .thenThrow(Exception('GPS error'));

        final cubit = await loadDriverToLoaded();
        await cubit.updateLocation(40.0, -74.0);

        expect(cubit.state, isA<DriverLoaded>());
        await cubit.close();
      });
    });

    group('updateDriverProfile', () {
      test('does nothing when state is not DriverLoaded', () async {
        final cubit = createCubit();
        await cubit.updateDriverProfile(vehicleType: 'car');
        verifyNever(() => mockDriverRepository.updateDriverProfile(
              driverId: any(named: 'driverId'),
            ));
        await cubit.close();
      });

      test('emits [DriverLoading, DriverLoaded] on success', () async {
        final updatedDriver =
            DriverModelFixture.create(vehicleType: 'car');
        when(() => mockDriverRepository.updateDriverProfile(
              driverId: 'driver-1',
              vehicleType: 'car',
            )).thenAnswer((_) async {});
        when(() => mockDriverRepository.getDriver('driver-1'))
            .thenAnswer((_) async => updatedDriver);

        final cubit = await loadDriverToLoaded();
        await cubit.updateDriverProfile(vehicleType: 'car');

        expect(cubit.state, isA<DriverLoaded>());
        final loaded = cubit.state as DriverLoaded;
        expect(loaded.driver.vehicleType, 'car');
        await cubit.close();
      });

      test('emits DriverError when updated driver is null', () async {
        when(() => mockDriverRepository.updateDriverProfile(
              driverId: any(named: 'driverId'),
              vehicleType: any(named: 'vehicleType'),
            )).thenAnswer((_) async {});
        when(() => mockDriverRepository.getDriver('driver-1'))
            .thenAnswer((_) async => null);

        final cubit = await loadDriverToLoaded();
        await cubit.updateDriverProfile(vehicleType: 'car');

        expect(cubit.state, isA<DriverError>());
        await cubit.close();
      });

      test('emits DriverError on exception', () async {
        when(() => mockDriverRepository.updateDriverProfile(
              driverId: any(named: 'driverId'),
              vehicleType: any(named: 'vehicleType'),
            )).thenThrow(Exception('Failed'));

        final cubit = await loadDriverToLoaded();
        await cubit.updateDriverProfile(vehicleType: 'car');

        expect(cubit.state, isA<DriverError>());
        await cubit.close();
      });
    });

    group('watchDriver', () {
      test('cancels previous subscription before starting new one', () async {
        final cubit = createCubit();
        final controller1 = StreamController<DriverModel?>();
        final controller2 = StreamController<DriverModel?>();

        when(() => mockDriverRepository.watchDriver('driver-1'))
            .thenAnswer((_) => controller1.stream);
        when(() => mockDriverRepository.watchDriver('driver-2'))
            .thenAnswer((_) => controller2.stream);

        cubit.watchDriver('driver-1');
        cubit.watchDriver('driver-2');

        expect(controller1.hasListener, false);
        expect(controller2.hasListener, true);

        await controller1.close();
        await controller2.close();
        await cubit.close();
      });

      test('emits DriverLoaded when stream emits driver', () async {
        final cubit = createCubit();
        final controller = StreamController<DriverModel?>();

        when(() => mockDriverRepository.watchDriver('driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchDriver('driver-1');

        controller.add(DriverModelFixture.create());

        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<DriverLoaded>());

        await controller.close();
        await cubit.close();
      });

      test('emits DriverError on stream error', () async {
        final cubit = createCubit();
        final controller = StreamController<DriverModel?>();

        when(() => mockDriverRepository.watchDriver('driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchDriver('driver-1');

        controller.addError(Exception('Stream error'));

        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<DriverError>());

        await controller.close();
        await cubit.close();
      });
    });

    test('close cancels driver subscription', () async {
      final cubit = createCubit();
      final controller = StreamController<DriverModel?>();

      when(() => mockDriverRepository.watchDriver('driver-1'))
          .thenAnswer((_) => controller.stream);

      cubit.watchDriver('driver-1');
      await cubit.close();

      expect(controller.hasListener, false);
      await controller.close();
    });
  });
}

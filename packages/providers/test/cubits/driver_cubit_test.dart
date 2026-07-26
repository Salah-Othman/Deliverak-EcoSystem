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
  late DriverCubit cubit;

  late MockFirebaseUser fakeUser;

  setUpAll(() {
    registerFallbackValue(MockFirebaseUser());
  });

  setUp(() {
    mockDriverRepository = MockDriverRepository();
    mockAuthRepository = MockAuthRepository();
    cubit = DriverCubit(
      driverRepository: mockDriverRepository,
      authRepository: mockAuthRepository,
    );
    fakeUser = MockFirebaseUser();
    when(() => fakeUser.uid).thenReturn('user-1');
  });

  tearDown(() {
    cubit.close();
  });

  group('DriverCubit', () {
    test('initial state is DriverInitial', () {
      expect(cubit.state, isA<DriverInitial>());
    });

    group('loadDriver', () {
      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverNotRegistered] when no current user',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return cubit;
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
          when(() => mockAuthRepository.currentUser).thenReturn(
            fakeUser,
          );
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => null);
          return cubit;
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
          when(() => mockAuthRepository.currentUser).thenReturn(
            fakeUser,
          );
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          return cubit;
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
          when(() => mockAuthRepository.currentUser).thenReturn(
            fakeUser,
          );
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenThrow(Exception('Firestore error'));
          return cubit;
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
          return cubit;
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
          when(() => mockAuthRepository.currentUser).thenReturn(
            fakeUser,
          );
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.createDriver(
                userId: 'user-1',
                vehicleType: 'motorcycle',
                vehicleNumber: 'ABC-1234',
                licenseNumber: 'DL-9876',
              )).thenAnswer((_) async => DriverModelFixture.create());
          return cubit;
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
          when(() => mockAuthRepository.currentUser).thenReturn(
            fakeUser,
          );
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.createDriver(
                userId: any(named: 'userId'),
                vehicleType: any(named: 'vehicleType'),
                vehicleNumber: any(named: 'vehicleNumber'),
                licenseNumber: any(named: 'licenseNumber'),
              )).thenThrow(Exception('Failed to create'));
          return cubit;
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
      blocTest<DriverCubit, DriverState>(
        'goOnline does nothing when state is not DriverLoaded',
        build: () => cubit,
        act: (cubit) => cubit.goOnline(),
        expect: () => [],
      );

      blocTest<DriverCubit, DriverState>(
        'goOffline does nothing when state is not DriverLoaded',
        build: () => cubit,
        act: (cubit) => cubit.goOffline(),
        expect: () => [],
      );

      blocTest<DriverCubit, DriverState>(
        'goOnline calls repository with true',
        build: () {
          when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
              .thenAnswer((_) async {});
          // Manually set state to DriverLoaded by calling loadDriver first
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.goOnline();
        },
        verify: (_) {
          verify(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
              .called(1);
        },
      );

      blocTest<DriverCubit, DriverState>(
        'goOffline calls repository with false',
        build: () {
          when(() => mockDriverRepository.updateOnlineStatus('driver-1', false))
              .thenAnswer((_) async {});
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.goOffline();
        },
        verify: (_) {
          verify(
              () => mockDriverRepository.updateOnlineStatus('driver-1', false))
              .called(1);
        },
      );

      blocTest<DriverCubit, DriverState>(
        'goOnline emits DriverError on failure',
        build: () {
          when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
              .thenThrow(Exception('Network error'));
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.goOnline();
        },
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
          isA<DriverError>(),
        ],
      );
    });

    group('updateLocation', () {
      test('does nothing when state is not DriverLoaded', () async {
        await cubit.updateLocation(40.0, -74.0);
        verifyNever(() => mockDriverRepository.updateLocation(any(), any(), any()));
      });

      test('calls repository when state is DriverLoaded', () async {
        when(() => mockDriverRepository.updateOnlineStatus('driver-1', true))
            .thenAnswer((_) async {});
        when(() => mockDriverRepository.updateLocation('driver-1', 40.0, -74.0))
            .thenAnswer((_) async {});
        when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
        when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
        when(() => mockDriverRepository.getDriverByUserId('user-1'))
            .thenAnswer((_) async => DriverModelFixture.create());

        await cubit.loadDriver();
        await cubit.updateLocation(40.0, -74.0);

        verify(() => mockDriverRepository.updateLocation('driver-1', 40.0, -74.0))
            .called(1);
      });

      test('silently handles errors from repository', () async {
        when(() => mockDriverRepository.updateLocation(any(), any(), any()))
            .thenThrow(Exception('GPS error'));
        when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
        when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
        when(() => mockDriverRepository.getDriverByUserId('user-1'))
            .thenAnswer((_) async => DriverModelFixture.create());

        await cubit.loadDriver();
        // Should not throw
        await cubit.updateLocation(40.0, -74.0);
        // State should still be DriverLoaded (error was swallowed)
        expect(cubit.state, isA<DriverLoaded>());
      });
    });

    group('updateDriverProfile', () {
      blocTest<DriverCubit, DriverState>(
        'does nothing when state is not DriverLoaded',
        build: () => cubit,
        act: (cubit) => cubit.updateDriverProfile(vehicleType: 'car'),
        expect: () => [],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverLoaded] on success',
        build: () {
          final driver = DriverModelFixture.create();
          final updatedDriver = DriverModelFixture.create(vehicleType: 'car');
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => driver);
          when(() => mockDriverRepository.updateDriverProfile(
                driverId: 'driver-1',
                vehicleType: 'car',
              )).thenAnswer((_) async {});
          when(() => mockDriverRepository.getDriver('driver-1'))
              .thenAnswer((_) async => updatedDriver);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.updateDriverProfile(vehicleType: 'car');
        },
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverError] when updated driver is null',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          when(() => mockDriverRepository.updateDriverProfile(
                driverId: any(named: 'driverId'),
                vehicleType: any(named: 'vehicleType'),
              )).thenAnswer((_) async {});
          when(() => mockDriverRepository.getDriver('driver-1'))
              .thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.updateDriverProfile(vehicleType: 'car');
        },
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
          isA<DriverLoading>(),
          isA<DriverError>(),
        ],
      );

      blocTest<DriverCubit, DriverState>(
        'emits [DriverLoading, DriverError] on exception',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);
          when(() => mockAuthRepository.currentUser!.uid).thenReturn('user-1');
          when(() => mockDriverRepository.getDriverByUserId('user-1'))
              .thenAnswer((_) async => DriverModelFixture.create());
          when(() => mockDriverRepository.updateDriverProfile(
                driverId: any(named: 'driverId'),
                vehicleType: any(named: 'vehicleType'),
              )).thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadDriver();
          await cubit.updateDriverProfile(vehicleType: 'car');
        },
        expect: () => [
          isA<DriverLoading>(),
          isA<DriverLoaded>(),
          isA<DriverLoading>(),
          isA<DriverError>(),
        ],
      );
    });

    group('watchDriver', () {
      test('cancels previous subscription before starting new one', () async {
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
      });

      test('emits DriverLoaded when stream emits driver', () async {
        final controller = StreamController<DriverModel?>();

        when(() => mockDriverRepository.watchDriver('driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchDriver('driver-1');

        controller.add(DriverModelFixture.create());

        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<DriverLoaded>());

        await controller.close();
      });

      test('emits DriverError on stream error', () async {
        final controller = StreamController<DriverModel?>();

        when(() => mockDriverRepository.watchDriver('driver-1'))
            .thenAnswer((_) => controller.stream);

        cubit.watchDriver('driver-1');

        controller.addError(Exception('Stream error'));

        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<DriverError>());

        await controller.close();
      });
    });

    test('close cancels driver subscription', () async {
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

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityCubit cubit;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityController = StreamController<List<ConnectivityResult>>();
    cubit = ConnectivityCubit(connectivity: mockConnectivity);

    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() {
    cubit.close();
    connectivityController.close();
  });

  group('ConnectivityCubit', () {
    test('initial state is ConnectivityInitial', () {
      expect(cubit.state, isA<ConnectivityInitial>());
    });

    group('init', () {
      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits ConnectivityOnline when wifi is available',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const ConnectivityOnline(result: ConnectivityResult.wifi),
        ],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits ConnectivityOnline when mobile is available',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.mobile]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const ConnectivityOnline(result: ConnectivityResult.mobile),
        ],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits ConnectivityOnline when ethernet is available',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.ethernet]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const ConnectivityOnline(result: ConnectivityResult.ethernet),
        ],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits ConnectivityOffline when result is none',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.none]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const ConnectivityOffline(),
        ],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits ConnectivityOnline when first result is none but second is wifi',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [
                    ConnectivityResult.none,
                    ConnectivityResult.wifi,
                  ]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          const ConnectivityOnline(result: ConnectivityResult.wifi),
        ],
      );
    });

    group('connectivity changes after init', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
      });

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits online when connectivity changes from offline to wifi',
        build: () {
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) async {
          await cubit.init();
          connectivityController.add([ConnectivityResult.wifi]);
        },
        expect: () => [
          const ConnectivityOffline(),
          const ConnectivityOnline(result: ConnectivityResult.wifi),
        ],
      );

      blocTest<ConnectivityCubit, ConnectivityState>(
        'emits offline when connectivity changes from online to none',
        build: () {
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);
          return ConnectivityCubit(connectivity: mockConnectivity);
        },
        act: (cubit) async {
          await cubit.init();
          connectivityController.add([ConnectivityResult.none]);
        },
        expect: () => [
          const ConnectivityOnline(result: ConnectivityResult.wifi),
          const ConnectivityOffline(),
        ],
      );
    });

    test('close cancels subscription', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final testCubit = ConnectivityCubit(connectivity: mockConnectivity);
      await testCubit.init();

      await testCubit.close();
      expect(connectivityController.hasListener, false);
    });
  });
}

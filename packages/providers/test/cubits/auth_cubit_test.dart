import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(PhoneAuthProvider.credential(
      verificationId: '',
      smsCode: '',
    ));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    cubit = AuthCubit(authRepository: mockAuthRepository);

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    cubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(cubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when authStateChanges emits null',
      build: () {
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => Stream.value(null));
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.initAuthListener(),
      expect: () => [isA<Unauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Unauthenticated] when getCurrentUser returns null after auth change',
      build: () {
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => Stream.value(null));
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);
        return AuthCubit(authRepository: mockAuthRepository);
      },
      act: (cubit) => cubit.initAuthListener(),
      expect: () => [isA<Unauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'verifyPhoneNumber emits [AuthLoading]',
      build: () {
        when(() => mockAuthRepository.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              onCompleted: any(named: 'onCompleted'),
              onFailed: any(named: 'onFailed'),
              onCodeSent: any(named: 'onCodeSent'),
              onCodeTimeout: any(named: 'onCodeTimeout'),
            )).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.verifyPhoneNumber('+1234567890'),
      expect: () => [isA<AuthLoading>()],
    );

    blocTest<AuthCubit, AuthState>(
      'submitOtp emits error when not in PhoneSubmitted state',
      build: () => cubit,
      act: (cubit) => cubit.submitOtp('123456'),
      expect: () => [isA<AuthError>()],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits [Unauthenticated]',
      build: () {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<Unauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits error on failure',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenThrow(Exception('sign out failed'));
        return cubit;
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<AuthError>()],
    );

    test('close cancels auth subscription', () async {
      final streamController = StreamController<User?>();
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => streamController.stream);

      final testCubit = AuthCubit(authRepository: mockAuthRepository);
      testCubit.initAuthListener();

      await testCubit.close();
      expect(streamController.hasListener, false);
      await streamController.close();
    });
  });
}

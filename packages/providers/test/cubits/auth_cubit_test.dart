import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

class FakeUser extends Fake implements User {
  FakeUser({this.uid = 'test-uid'});
  @override
  final String uid;
}

class FakeFirebaseAuthException extends Fake implements FirebaseAuthException {
  FakeFirebaseAuthException(this._code, [this._message]);
  final String _code;
  final String? _message;

  @override
  String get code => _code;

  @override
  String? get message => _message;
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(PhoneAuthProvider.credential(
      verificationId: '',
      smsCode: '',
    ));
    registerFallbackValue(UserRole.customer);
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

    // ── initAuthListener ────────────────────────────────

    group('initAuthListener', () {
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
        'emits [Authenticated] when authStateChanges emits user with name',
        build: () {
          final user = UserModelFixture.create(name: 'John');
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => user);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.initAuthListener(),
        expect: () => [isA<Authenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [ProfileSetup] when authStateChanges emits user with empty name',
        build: () {
          final user = UserModelFixture.create(name: '');
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => user);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.initAuthListener(),
        expect: () => [isA<ProfileSetup>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthError] when getCurrentUser throws',
        build: () {
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenThrow(Exception('Firestore error'));
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) => cubit.initAuthListener(),
        expect: () => [isA<AuthError>()],
      );

      blocTest<AuthCubit, AuthState>(
        'does not emit Unauthenticated when state is PhoneSubmitted',
        build: () {
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(null));
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) async {
          // Manually set to PhoneSubmitted
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((_) async {});

          // Trigger verify to get to PhoneSubmitted via onCodeSent callback
          final completer = Completer<void>();
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-123', null);
            completer.complete();
          });

          await cubit.verifyPhoneNumber('+1234567890');
          await completer.future;

          // Now the auth state changes should not emit Unauthenticated
          // since state is PhoneSubmitted
          expect(cubit.state, isA<PhoneSubmitted>());
        },
      );
    });

    // ── verifyPhoneNumber ───────────────────────────────

    group('verifyPhoneNumber', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading]',
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
        'emits [AuthLoading, PhoneSubmitted] on code sent',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-123', 456);
          });
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('+1234567890'),
        expect: () => [
          isA<AuthLoading>(),
          const TypeMatcher<PhoneSubmitted>().having(
            (s) => s.verificationId,
            'verificationId',
            'vid-123',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'PhoneSubmitted contains phoneNumber and resendToken',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-456', 789);
          });
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('+1987654321'),
        verify: (cubit) {
          final state = cubit.state as PhoneSubmitted;
          expect(state.phoneNumber, '+1987654321');
          expect(state.verificationId, 'vid-456');
          expect(state.resendToken, 789);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on verification failed',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onFailed =
                invocation.namedArguments[#onFailed] as Function;
            onFailed(FakeFirebaseAuthException('invalid-phone-number'));
          });
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('bad'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.code, 'invalid-phone-number');
          expect(error.message, contains('phone number'));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on code timeout',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeTimeout =
                invocation.namedArguments[#onCodeTimeout] as Function;
            onCodeTimeout('vid-expired');
          });
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('+1234567890'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.message, contains('timed out'));
          expect(error.isRetryable, isTrue);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when verifyPhoneNumber throws',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenThrow(Exception('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('+1234567890'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthError with retryable flag for network exceptions',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenThrow(const NetworkException());
          return cubit;
        },
        act: (cubit) => cubit.verifyPhoneNumber('+1234567890'),
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.isRetryable, isTrue);
          expect(error.code, 'network');
        },
      );
    });

    // ── submitOtp ───────────────────────────────────────

    group('submitOtp', () {
      blocTest<AuthCubit, AuthState>(
        'emits error when not in PhoneSubmitted state',
        build: () => cubit,
        act: (cubit) => cubit.submitOtp('123456'),
        expect: () => [isA<AuthError>()],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.isRetryable, isTrue);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, PhoneSubmitted, AuthLoading] on successful OTP submit',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-123', null);
          });

          when(() => mockAuthRepository.signInWithCredential(any()))
              .thenAnswer((_) async => UserModelFixture.create(name: 'John'));

          return cubit;
        },
        act: (cubit) async {
          await cubit.verifyPhoneNumber('+1234567890');
          await cubit.submitOtp('123456');
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<PhoneSubmitted>(),
          isA<AuthLoading>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when signInWithCredential fails',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-123', null);
          });

          when(() => mockAuthRepository.signInWithCredential(any()))
              .thenThrow(Exception('Invalid OTP'));

          return cubit;
        },
        act: (cubit) async {
          await cubit.verifyPhoneNumber('+1234567890');
          await cubit.submitOtp('000000');
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<PhoneSubmitted>(),
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    // ── resendOtp ───────────────────────────────────────

    group('resendOtp', () {
      blocTest<AuthCubit, AuthState>(
        'calls verifyPhoneNumber with stored phone number',
        build: () {
          when(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).thenAnswer((invocation) async {
            final onCodeSent =
                invocation.namedArguments[#onCodeSent] as Function;
            onCodeSent('vid-1', null);
          });
          return cubit;
        },
        act: (cubit) async {
          await cubit.verifyPhoneNumber('+1234567890');
          await cubit.resendOtp();
        },
        verify: (cubit) {
          verify(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: '+1234567890',
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              )).called(2);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when not in PhoneSubmitted state',
        build: () => cubit,
        act: (cubit) => cubit.resendOtp(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockAuthRepository.verifyPhoneNumber(
                phoneNumber: any(named: 'phoneNumber'),
                onCompleted: any(named: 'onCompleted'),
                onFailed: any(named: 'onFailed'),
                onCodeSent: any(named: 'onCodeSent'),
                onCodeTimeout: any(named: 'onCodeTimeout'),
              ));
        },
      );
    });

    // ── selectRole ──────────────────────────────────────

    group('selectRole', () {
      blocTest<AuthCubit, AuthState>(
        'emits ProfileSetup with selectedRole when in ProfileSetup state',
        build: () {
          final user = UserModelFixture.create(name: '');
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => user);
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) async {
          cubit.initAuthListener();
          await Future<void>.delayed(Duration.zero);
          cubit.selectRole(UserRole.driver);
        },
        expect: () => [
          isA<ProfileSetup>(),
          const TypeMatcher<ProfileSetup>().having(
            (s) => s.selectedRole,
            'selectedRole',
            UserRole.driver,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when not in ProfileSetup state',
        build: () => cubit,
        act: (cubit) => cubit.selectRole(UserRole.vendor),
        expect: () => [],
      );
    });

    // ── completeProfile ─────────────────────────────────

    group('completeProfile', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, Authenticated] on success',
        build: () {
          final user = UserModelFixture.create(name: '');
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => user);
          when(() => mockAuthRepository.completeProfile(
                uid: any(named: 'uid'),
                name: any(named: 'name'),
                role: any(named: 'role'),
                email: any(named: 'email'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async {});
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) async {
          cubit.initAuthListener();
          await Future<void>.delayed(Duration.zero);
          await cubit.completeProfile(
            name: 'John Doe',
            role: UserRole.customer,
            email: 'john@example.com',
          );
        },
        expect: () => [
          isA<ProfileSetup>(),
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
        verify: (cubit) {
          final state = cubit.state as Authenticated;
          expect(state.user.name, 'John Doe');
          expect(state.user.email, 'john@example.com');
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when completeProfile fails',
        build: () {
          final user = UserModelFixture.create(name: '');
          when(() => mockAuthRepository.authStateChanges)
              .thenAnswer((_) => Stream.value(FakeUser()));
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => user);
          when(() => mockAuthRepository.completeProfile(
                uid: any(named: 'uid'),
                name: any(named: 'name'),
                role: any(named: 'role'),
                email: any(named: 'email'),
                profileImage: any(named: 'profileImage'),
              )).thenThrow(Exception('Profile update failed'));
          return AuthCubit(authRepository: mockAuthRepository);
        },
        act: (cubit) async {
          cubit.initAuthListener();
          await Future<void>.delayed(Duration.zero);
          await cubit.completeProfile(
            name: 'John',
            role: UserRole.customer,
          );
        },
        expect: () => [
          isA<ProfileSetup>(),
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when not in ProfileSetup state',
        build: () => cubit,
        act: (cubit) => cubit.completeProfile(
          name: 'John',
          role: UserRole.customer,
        ),
        expect: () => [],
      );
    });

    // ── updateProfile ───────────────────────────────────

    group('updateProfile', () {
      blocTest<AuthCubit, AuthState>(
        'reloads user after successful update',
        build: () {
          when(() => mockAuthRepository.updateUserProfile(
                uid: any(named: 'uid'),
                name: any(named: 'name'),
                email: any(named: 'email'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async {});
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => UserModelFixture.create(name: 'John'));
          return cubit;
        },
        act: (cubit) async {
          cubit.emit(Authenticated(UserModelFixture.create(name: 'John')));
          await cubit.updateProfile(name: 'John Updated');
        },
        verify: (cubit) {
          verify(() => mockAuthRepository.updateUserProfile(
                uid: 'test-uid',
                name: 'John Updated',
                email: null,
                profileImage: null,
              )).called(1);
          verify(() => mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits AuthError when updateUserProfile throws',
        build: () {
          when(() => mockAuthRepository.updateUserProfile(
                uid: any(named: 'uid'),
                name: any(named: 'name'),
                email: any(named: 'email'),
                profileImage: any(named: 'profileImage'),
              )).thenThrow(Exception('Update failed'));
          return cubit;
        },
        act: (cubit) async {
          cubit.emit(Authenticated(UserModelFixture.create(name: 'John')));
          await cubit.updateProfile(name: 'New Name');
        },
        expect: () => [
          isA<Authenticated>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'does nothing when not Authenticated',
        build: () => cubit,
        act: (cubit) => cubit.updateProfile(name: 'Test'),
        expect: () => [],
      );
    });

    // ── signInWithEmail ─────────────────────────────────

    group('signInWithEmail', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading] then stays AuthLoading on success',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(
                any(), any(),
              )).thenAnswer((_) async => UserModelFixture.create());
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('test@test.com', 'pass123'),
        expect: () => [isA<AuthLoading>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on FirebaseAuthException',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenThrow(FakeFirebaseAuthException('wrong-password'));
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('test@test.com', 'wrong'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.code, 'wrong-password');
          expect(error.message, contains('Incorrect password'));
          expect(error.isRetryable, isFalse);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on generic exception',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenThrow(const NetworkException());
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('test@test.com', 'pass'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.isRetryable, isTrue);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'includes previousState in AuthError',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenThrow(Exception('fail'));
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('test@test.com', 'pass'),
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.previousState, isA<AuthInitial>());
        },
      );
    });

    // ── signUpWithEmail ─────────────────────────────────

    group('signUpWithEmail', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading] on success',
        build: () {
          when(() => mockAuthRepository.signUpWithEmail(
                any(),
                any(),
                name: any(named: 'name'),
              )).thenAnswer((_) async => UserModelFixture.create());
          return cubit;
        },
        act: (cubit) =>
            cubit.signUpWithEmail('test@test.com', 'pass123', name: 'John'),
        expect: () => [isA<AuthLoading>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on FirebaseAuthException',
        build: () {
          when(() => mockAuthRepository.signUpWithEmail(
                any(),
                any(),
                name: any(named: 'name'),
              )).thenThrow(FakeFirebaseAuthException('email-already-in-use'));
          return cubit;
        },
        act: (cubit) =>
            cubit.signUpWithEmail('test@test.com', 'pass123', name: 'John'),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.code, 'email-already-in-use');
          expect(error.message, contains('already exists'));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'maps weak-password error correctly',
        build: () {
          when(() => mockAuthRepository.signUpWithEmail(
                any(),
                any(),
                name: any(named: 'name'),
              )).thenThrow(FakeFirebaseAuthException('weak-password'));
          return cubit;
        },
        act: (cubit) =>
            cubit.signUpWithEmail('test@test.com', '123', name: 'John'),
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.message, contains('weak'));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'marks network errors as retryable',
        build: () {
          when(() => mockAuthRepository.signUpWithEmail(
                any(),
                any(),
                name: any(named: 'name'),
              )).thenThrow(FakeFirebaseAuthException('network-request-failed'));
          return cubit;
        },
        act: (cubit) =>
            cubit.signUpWithEmail('test@test.com', 'pass', name: 'John'),
        verify: (cubit) {
          final error = cubit.state as AuthError;
          expect(error.isRetryable, isTrue);
        },
      );
    });

    // ── signOut ─────────────────────────────────────────

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits [Unauthenticated]',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [isA<Unauthenticated>()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits error on failure',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenThrow(Exception('sign out failed'));
          return cubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [isA<AuthError>()],
      );
    });

    // ── FirebaseAuthException mapping ───────────────────

    group('_mapAuthError', () {
      AuthCubit buildCubitWithError(String code, [String? message]) {
        when(() => mockAuthRepository.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              onCompleted: any(named: 'onCompleted'),
              onFailed: any(named: 'onFailed'),
              onCodeSent: any(named: 'onCodeSent'),
              onCodeTimeout: any(named: 'onCodeTimeout'),
            )).thenAnswer((invocation) async {
          final onFailed =
              invocation.namedArguments[#onFailed] as Function;
          onFailed(FakeFirebaseAuthException(code, message));
        });
        return AuthCubit(authRepository: mockAuthRepository);
      }

      test('maps invalid-phone-number', () async {
        final c = buildCubitWithError('invalid-phone-number');
        await c.verifyPhoneNumber('+bad');
        expect((c.state as AuthError).message, contains('phone number'));
        await c.close();
      });

      test('maps invalid-verification-code', () async {
        final c = buildCubitWithError('invalid-verification-code');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('OTP code'));
        await c.close();
      });

      test('maps invalid-verification-id', () async {
        final c = buildCubitWithError('invalid-verification-id');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('expired'));
        await c.close();
      });

      test('maps session-expired', () async {
        final c = buildCubitWithError('session-expired');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('expired'));
        await c.close();
      });

      test('maps too-many-requests as retryable', () async {
        final c = buildCubitWithError('too-many-requests');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).isRetryable, isTrue);
        await c.close();
      });

      test('maps quota-exceeded', () async {
        final c = buildCubitWithError('quota-exceeded');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('quota'));
        await c.close();
      });

      test('maps network-request-failed as retryable', () async {
        final c = buildCubitWithError('network-request-failed');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).isRetryable, isTrue);
        await c.close();
      });

      test('maps invalid-email', () async {
        final c = buildCubitWithError('invalid-email');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('email'));
        await c.close();
      });

      test('maps user-disabled', () async {
        final c = buildCubitWithError('user-disabled');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('disabled'));
        await c.close();
      });

      test('maps user-not-found', () async {
        final c = buildCubitWithError('user-not-found');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('No account'));
        await c.close();
      });

      test('maps wrong-password', () async {
        final c = buildCubitWithError('wrong-password');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('Incorrect'));
        await c.close();
      });

      test('maps email-already-in-use', () async {
        final c = buildCubitWithError('email-already-in-use');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('already exists'));
        await c.close();
      });

      test('maps weak-password', () async {
        final c = buildCubitWithError('weak-password');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('weak'));
        await c.close();
      });

      test('maps operation-not-allowed', () async {
        final c = buildCubitWithError('operation-not-allowed');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('not enabled'));
        await c.close();
      });

      test('maps unknown code to error.message fallback', () async {
        final c = buildCubitWithError('custom-code', 'Custom error msg');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, 'Custom error msg');
        await c.close();
      });

      test('maps unknown code with null message to default', () async {
        final c = buildCubitWithError('unknown-code');
        await c.verifyPhoneNumber('+123');
        expect((c.state as AuthError).message, contains('Something went wrong'));
        await c.close();
      });
    });

    // ── close ───────────────────────────────────────────

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

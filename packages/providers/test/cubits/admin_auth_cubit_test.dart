import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AdminAuthCubit cubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    cubit = AdminAuthCubit(authRepository: mockAuthRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AdminAuthCubit', () {
    test('initial state is AdminAuthInitial', () {
      expect(cubit.state, isA<AdminAuthInitial>());
    });

    group('signInWithEmail', () {
      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits [AdminAuthLoading, AdminAuthenticated] on admin sign-in success',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenAnswer(
            (_) async =>
                UserModelFixture.create(uid: 'admin-1', role: UserRole.admin),
          );
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('admin@test.com', 'password123'),
        expect: () => [
          isA<AdminAuthLoading>(),
          isA<AdminAuthenticated>(),
        ],
        verify: (cubit) {
          final authed = cubit.state as AdminAuthenticated;
          expect(authed.user.role, UserRole.admin);
        },
      );

      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits [AdminAuthLoading, AdminAuthError] when user is not admin',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenAnswer(
            (_) async => UserModelFixture.create(
                uid: 'u1', role: UserRole.customer),
          );
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('user@test.com', 'password123'),
        expect: () => [
          isA<AdminAuthLoading>(),
          isA<AdminAuthError>(),
        ],
        verify: (cubit) {
          verify(() => mockAuthRepository.signOut()).called(1);
          final error = cubit.state as AdminAuthError;
          expect(error.message, contains('Access denied'));
        },
      );

      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits [AdminAuthLoading, AdminAuthError] on exception',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenThrow(Exception('Invalid credentials'));
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('bad@test.com', 'wrong'),
        expect: () => [
          isA<AdminAuthLoading>(),
          isA<AdminAuthError>(),
        ],
      );

      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits [AdminAuthLoading, AdminAuthError] with network message',
        build: () {
          when(() => mockAuthRepository.signInWithEmail(any(), any()))
              .thenThrow(Exception('network error occurred'));
          return cubit;
        },
        act: (cubit) => cubit.signInWithEmail('a@b.com', 'pass'),
        expect: () => [
          isA<AdminAuthLoading>(),
          isA<AdminAuthError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as AdminAuthError;
          expect(error.isRetryable, isTrue);
          expect(error.message, contains('internet connection'));
        },
      );
    });

    group('initAuthListener', () {
      test('emits AdminAuthenticated when auth state changes to admin user',
          () async {
        final controller = StreamController<User?>();
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => controller.stream);
        when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
          (_) async =>
              UserModelFixture.create(uid: 'admin-1', role: UserRole.admin),
        );

        cubit.initAuthListener();
        controller.add(null); // simulate initial null
        await Future.delayed(Duration.zero);

        // Then sign in
        controller.add(FakeFirebaseUser(uid: 'admin-1'));
        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<AdminAuthenticated>());
        await cubit.close();
        await controller.close();
      });

      test('emits AdminUnauthenticated when auth state changes to null',
          () async {
        final controller = StreamController<User?>();
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => controller.stream);

        cubit.initAuthListener();
        controller.add(null);
        await Future.delayed(Duration.zero);

        expect(cubit.state, isA<AdminUnauthenticated>());
        await cubit.close();
        await controller.close();
      });
    });

    group('signOut', () {
      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits AdminUnauthenticated on signOut success',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [isA<AdminUnauthenticated>()],
      );

      blocTest<AdminAuthCubit, AdminAuthState>(
        'emits AdminAuthError on signOut failure',
        build: () {
          when(() => mockAuthRepository.signOut())
              .thenThrow(Exception('Sign out failed'));
          return cubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [isA<AdminAuthError>()],
      );
    });

    test('close cancels auth subscription', () async {
      final controller = StreamController<User?>();
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => controller.stream);

      cubit.initAuthListener();
      await cubit.close();

      expect(controller.hasListener, isFalse);
      await controller.close();
    });
  });
}

class FakeFirebaseUser extends Fake implements User {
  FakeFirebaseUser({required this.uid});

  @override
  final String uid;
}

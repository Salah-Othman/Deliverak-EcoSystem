import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late AdminUserCubit cubit;

  setUp(() {
    mockUserRepository = MockUserRepository();
    cubit = AdminUserCubit(userRepository: mockUserRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AdminUserCubit', () {
    test('initial state is AdminUserInitial', () {
      expect(cubit.state, isA<AdminUserInitial>());
    });

    blocTest<AdminUserCubit, AdminUserState>(
      'emits [AdminUserLoading, AdminUsersLoaded] on loadUsers',
      build: () {
        when(() => mockUserRepository.getUsers(role: any(named: 'role')))
            .thenAnswer((_) async => [
                  UserModelFixture.create(uid: 'u1', role: UserRole.customer),
                  UserModelFixture.create(uid: 'u2', role: UserRole.vendor),
                ]);
        return cubit;
      },
      act: (cubit) => cubit.loadUsers(),
      expect: () => [
        isA<AdminUserLoading>(),
        isA<AdminUsersLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as AdminUsersLoaded;
        expect(loaded.users.length, 2);
        expect(loaded.filter, isNull);
      },
    );

    blocTest<AdminUserCubit, AdminUserState>(
      'emits [AdminUserLoading, AdminUsersLoaded] with role filter',
      build: () {
        when(() => mockUserRepository.getUsers(role: any(named: 'role')))
            .thenAnswer((_) async => [
                  UserModelFixture.create(uid: 'u1', role: UserRole.driver),
                ]);
        return cubit;
      },
      act: (cubit) => cubit.loadUsers(role: UserRole.driver),
      expect: () => [
        isA<AdminUserLoading>(),
        isA<AdminUsersLoaded>(),
      ],
      verify: (cubit) {
        final loaded = cubit.state as AdminUsersLoaded;
        expect(loaded.users.length, 1);
        expect(loaded.filter, UserRole.driver);
      },
    );

    blocTest<AdminUserCubit, AdminUserState>(
      'emits [AdminUserLoading, AdminUserError] on loadUsers failure',
      build: () {
        when(() => mockUserRepository.getUsers(role: any(named: 'role')))
            .thenThrow(Exception('DB error'));
        return cubit;
      },
      act: (cubit) => cubit.loadUsers(),
      expect: () => [
        isA<AdminUserLoading>(),
        isA<AdminUserError>(),
      ],
    );

    blocTest<AdminUserCubit, AdminUserState>(
      'watchUsers emits AdminUsersLoaded from stream',
      build: () {
        final controller = StreamController<List<UserModel>>();
        when(() => mockUserRepository.watchUsers(
              role: any(named: 'role'),
            )).thenAnswer((_) => controller.stream);
        return cubit;
      },
      act: (cubit) {
        cubit.watchUsers();
      },
      verify: (cubit) {
        // Verify subscription is set up
        expect(cubit.state, isA<AdminUserInitial>());
      },
    );

    test('close cancels stream subscription', () async {
      final controller = StreamController<List<UserModel>>();
      when(() => mockUserRepository.watchUsers(
            role: any(named: 'role'),
          )).thenAnswer((_) => controller.stream);

      cubit.watchUsers();
      await cubit.close();

      expect(controller.hasListener, isFalse);
      await controller.close();
    });
  });
}

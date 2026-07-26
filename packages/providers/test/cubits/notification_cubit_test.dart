import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockNotificationRepository mockNotificationRepository;
  late NotificationCubit cubit;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    cubit = NotificationCubit(
      notificationRepository: mockNotificationRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('NotificationCubit', () {
    test('initial state is NotificationInitial', () {
      expect(cubit.state, isA<NotificationInitial>());
    });

    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoading, NotificationsLoaded] on loadNotifications',
      build: () {
        when(() => mockNotificationRepository.getNotifications('u1'))
            .thenAnswer((_) async => [NotificationModelFixture.create()]);
        when(() => mockNotificationRepository.getUnreadCount('u1'))
            .thenAnswer((_) async => 1);
        return cubit;
      },
      act: (cubit) => cubit.loadNotifications('u1'),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationsLoaded>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'emits [NotificationLoading, NotificationError] on loadNotifications failure',
      build: () {
        when(() => mockNotificationRepository.getNotifications('u1'))
            .thenThrow(Exception('failed'));
        return cubit;
      },
      act: (cubit) => cubit.loadNotifications('u1'),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAsRead reloads notifications',
      build: () {
        when(() => mockNotificationRepository.markAsRead('n1'))
            .thenAnswer((_) async {});
        when(() => mockNotificationRepository.getNotifications('u1'))
            .thenAnswer((_) async => []);
        when(() => mockNotificationRepository.getUnreadCount('u1'))
            .thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.markAsRead('n1', 'u1'),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationsLoaded>(),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'markAllAsRead reloads notifications',
      build: () {
        when(() => mockNotificationRepository.markAllAsRead('u1'))
            .thenAnswer((_) async {});
        when(() => mockNotificationRepository.getNotifications('u1'))
            .thenAnswer((_) async => []);
        when(() => mockNotificationRepository.getUnreadCount('u1'))
            .thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.markAllAsRead('u1'),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationsLoaded>(),
      ],
    );

    test('close cancels notifications subscription', () async {
      final controller = StreamController<List<NotificationModel>>();
      when(() => mockNotificationRepository.watchNotifications('u1'))
          .thenAnswer((_) => controller.stream);

      cubit.watchNotifications('u1');
      await cubit.close();

      expect(controller.hasListener, false);
      await controller.close();
    });
  });
}

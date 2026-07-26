import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import '../helpers/test_models.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates valid model with all fields', () {
      final now = DateTime(2024);
      final map = {
        'uid': 'uid-1',
        'name': 'John',
        'email': 'john@test.com',
        'phone': '+1234567890',
        'role': 'vendor',
        'fcmToken': 'token-123',
        'profileImage': 'https://img.jpg',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'uid-1');
      expect(user.name, 'John');
      expect(user.email, 'john@test.com');
      expect(user.phone, '+1234567890');
      expect(user.role, UserRole.vendor);
      expect(user.fcmToken, 'token-123');
      expect(user.profileImage, 'https://img.jpg');
    });

    test('fromMap handles missing optional fields', () {
      final user = UserModel.fromMap({});

      expect(user.uid, '');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.phone, '');
      expect(user.role, UserRole.customer);
      expect(user.fcmToken, null);
      expect(user.profileImage, null);
    });

    test('fromMap defaults to customer for unknown role', () {
      final user = UserModel.fromMap({'role': 'unknown'});
      expect(user.role, UserRole.customer);
    });

    test('toMap produces correct map', () {
      final user = UserModelFixture.create();
      final map = user.toMap();

      expect(map['uid'], user.uid);
      expect(map['name'], user.name);
      expect(map['role'], 'customer');
      expect(map['createdAt'], isA<String>());
    });

    test('toMap round-trips through fromMap', () {
      final user = UserModelFixture.create();
      final roundTripped = UserModel.fromMap(user.toMap());

      expect(roundTripped.uid, user.uid);
      expect(roundTripped.name, user.name);
      expect(roundTripped.email, user.email);
      expect(roundTripped.phone, user.phone);
      expect(roundTripped.role, user.role);
    });

    test('copyWith changes specified fields', () {
      final user = UserModelFixture.create(name: 'Old Name');
      final updated = user.copyWith(name: 'New Name');

      expect(updated.name, 'New Name');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
      expect(updated.updatedAt.isAfter(user.updatedAt), true);
    });

    test('copyWith preserves unchanged fields', () {
      final user = UserModelFixture.create();
      final updated = user.copyWith(email: 'new@test.com');

      expect(updated.email, 'new@test.com');
      expect(updated.name, user.name);
      expect(updated.phone, user.phone);
      expect(updated.role, user.role);
    });

    test('Equatable considers equal models equal', () {
      final user1 = UserModelFixture.create();
      final user2 = UserModelFixture.create();

      expect(user1, equals(user2));
    });
  });
}

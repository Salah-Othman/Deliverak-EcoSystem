// ignore_for_file: subtype_of_sealed_class
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

class MockFirestoreService extends Mock implements IFirestoreService {}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool _exists;
  final String _id;

  FakeDocumentSnapshot(this._data, {bool exists = true})
      : _exists = exists,
        _id = _data['uid'] ?? 'unknown';

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;
}

class FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeQueryDocumentSnapshot(this._data, {String? id})
      : _id = id ?? (_data['uid'] ?? 'unknown');

  @override
  Map<String, dynamic> data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;
}

class FakeQuerySnapshot extends Fake implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  FakeQuerySnapshot(List<DocumentSnapshot> docs)
      : _docs = docs
            .map((d) => FakeQueryDocumentSnapshot(
                  d.data() as Map<String, dynamic>,
                  id: d.id,
                ))
            .toList();

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  int get size => _docs.length;
}

void main() {
  late MockFirestoreService mockFirestoreService;
  late UserRepository userRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    userRepository = UserRepository(firestoreService: mockFirestoreService);
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(
      field: 'test',
      value: 'test',
    ));
  });

  Map<String, dynamic> userMap({
    String uid = 'u1',
    String name = 'Test User',
    String email = 'test@example.com',
    String phone = '+1234567890',
    String role = 'customer',
  }) {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcmToken': null,
      'profileImage': null,
      'createdAt': DateTime(2024).toIso8601String(),
      'updatedAt': DateTime(2024).toIso8601String(),
    };
  }

  group('UserRepository', () {
    group('getUsers', () {
      test('returns list of users without filter', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1')),
            FakeDocumentSnapshot(userMap(uid: 'u2')),
          ]),
        );

        final users = await userRepository.getUsers();

        expect(users.length, 2);
        expect(users[0].uid, 'u1');
        expect(users[1].uid, 'u2');
      });

      test('filters users by role', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1', role: 'customer')),
            FakeDocumentSnapshot(userMap(uid: 'u2', role: 'driver')),
            FakeDocumentSnapshot(userMap(uid: 'u3', role: 'customer')),
          ]),
        );

        final users = await userRepository.getUsers(role: UserRole.customer);

        expect(users.length, 2);
        expect(users.every((u) => u.role == UserRole.customer), isTrue);
      });
    });

    group('getUser', () {
      test('returns user when document exists', () async {
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot(userMap(uid: 'u1')),
        );

        final user = await userRepository.getUser('u1');

        expect(user, isNotNull);
        expect(user!.uid, 'u1');
        expect(user.name, 'Test User');
      });

      test('returns null when document does not exist', () async {
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot({}, exists: false),
        );

        final user = await userRepository.getUser('nonexistent');

        expect(user, isNull);
      });
    });

    group('getUsersCount', () {
      test('returns count of all users', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1')),
            FakeDocumentSnapshot(userMap(uid: 'u2')),
            FakeDocumentSnapshot(userMap(uid: 'u3')),
          ]),
        );

        final count = await userRepository.getUsersCount();

        expect(count, 3);
      });
    });

    group('getUsersCountByRole', () {
      test('returns count of users with specific role', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1', role: 'driver')),
            FakeDocumentSnapshot(userMap(uid: 'u2', role: 'driver')),
          ]),
        );

        final count = await userRepository.getUsersCountByRole(UserRole.driver);

        expect(count, 2);
      });
    });

    group('watchUsers', () {
      test('returns stream of users', () async {
        when(() => mockFirestoreService.watchDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) => Stream.value(FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1')),
          ])),
        );

        final users = await userRepository.watchUsers().first;

        expect(users.length, 1);
        expect(users[0].uid, 'u1');
      });

      test('filters by role in stream', () async {
        when(() => mockFirestoreService.watchDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) => Stream.value(FakeQuerySnapshot([
            FakeDocumentSnapshot(userMap(uid: 'u1', role: 'admin')),
            FakeDocumentSnapshot(userMap(uid: 'u2', role: 'vendor')),
          ])),
        );

        final users = await userRepository.watchUsers(role: UserRole.admin).first;

        expect(users.length, 1);
        expect(users[0].role, UserRole.admin);
      });
    });
  });
}

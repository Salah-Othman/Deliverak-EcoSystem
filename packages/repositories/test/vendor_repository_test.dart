// ignore_for_file: subtype_of_sealed_class
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

class MockFirestoreService extends Mock implements IFirestoreService {}

class MockCacheService extends Mock implements ICacheService {}

class FakeDocumentSnapshot extends Fake implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final bool _exists;
  final String _id;

  FakeDocumentSnapshot(this._data, {String? id, bool exists = true})
      : _exists = exists,
        _id = id ?? (_data['uid'] ?? 'unknown');

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
  late MockCacheService mockCacheService;
  late VendorRepository vendorRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockCacheService = MockCacheService();
    vendorRepository = VendorRepository(
      firestoreService: mockFirestoreService,
      cacheService: mockCacheService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(field: 'test', value: 'test'));
    registerFallbackValue(<String, dynamic>{});
  });

  Map<String, dynamic> vendorMap({
    String vendorId = 'v1',
    String name = 'Test Vendor',
    String category = 'food',
    bool isOpen = true,
    double rating = 4.5,
  }) {
    return {
      'vendorId': vendorId,
      'name': name,
      'description': 'A test vendor',
      'image': 'https://example.com/image.png',
      'category': category,
      'lat': 0.0,
      'lng': 0.0,
      'address': '123 Test St',
      'rating': rating,
      'totalOrders': 10,
      'isOpen': isOpen,
      'ownerId': 'owner1',
      'createdAt': DateTime(2024).toIso8601String(),
    };
  }

  group('VendorRepository', () {
    group('getVendors', () {
      test('returns vendors from Firestore and caches result', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1'), id: 'v1'),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v2'), id: 'v2'),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendors = await vendorRepository.getVendors();

        expect(vendors.length, 2);
        expect(vendors[0].vendorId, 'v1');
        expect(vendors[1].vendorId, 'v2');
        verify(() => mockCacheService.put<String>(any(), any(), any()))
            .called(1);
      });

      test('returns vendors from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            vendorMap(vendorId: 'v1'),
            vendorMap(vendorId: 'v2'),
          ]),
        );

        final vendors = await vendorRepository.getVendors();

        expect(vendors.length, 2);
        expect(vendors[0].vendorId, 'v1');
        verifyNever(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
              limit: any(named: 'limit'),
            ));
      });

      test('filters by category', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1', category: 'food')),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v2', category: 'grocery')),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v3', category: 'food')),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendors = await vendorRepository.getVendors(
          category: DeliveryType.food,
        );

        expect(vendors.length, 2);
        expect(vendors.every((v) => v.category == DeliveryType.food), isTrue);
      });

      test('filters by isOpen', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1', isOpen: true)),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v2', isOpen: false)),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendors = await vendorRepository.getVendors(isOpen: true);

        expect(vendors.length, 1);
        expect(vendors[0].isOpen, isTrue);
      });

      test('applies limit', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
              limit: any(named: 'limit'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1')),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v2')),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendors = await vendorRepository.getVendors(limit: 2);

        expect(vendors.length, 2);
      });
    });

    group('getVendor', () {
      test('returns vendor when document exists', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot(vendorMap(vendorId: 'v1'), id: 'v1'),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendor = await vendorRepository.getVendor('v1');

        expect(vendor, isNotNull);
        expect(vendor!.vendorId, 'v1');
        expect(vendor.name, 'Test Vendor');
      });

      test('returns null when document does not exist', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot({}, exists: false),
        );

        final vendor = await vendorRepository.getVendor('nonexistent');

        expect(vendor, isNull);
      });

      test('returns vendor from cache', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(jsonEncode(vendorMap(vendorId: 'v1')));

        final vendor = await vendorRepository.getVendor('v1');

        expect(vendor, isNotNull);
        expect(vendor!.vendorId, 'v1');
        verifyNever(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            ));
      });
    });

    group('watchVendor', () {
      test('streams vendor updates', () async {
        when(() => mockFirestoreService.watchDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) => Stream.value(
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1'), id: 'v1'),
          ),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendor = await vendorRepository.watchVendor('v1').first;

        expect(vendor, isNotNull);
        expect(vendor!.vendorId, 'v1');
      });

      test('returns null when vendor does not exist in stream', () async {
        when(() => mockFirestoreService.watchDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) => Stream.value(
            FakeDocumentSnapshot({}, exists: false),
          ),
        );

        final vendor = await vendorRepository.watchVendor('nonexistent').first;

        expect(vendor, isNull);
      });
    });

    group('searchVendors', () {
      test('searches by name case-insensitive', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1', name: 'Pizza Palace')),
            FakeDocumentSnapshot(vendorMap(vendorId: 'v2', name: 'Burger Barn')),
            FakeDocumentSnapshot(
                vendorMap(vendorId: 'v3', name: 'Pizza Place')),
          ]),
        );

        final vendors = await vendorRepository.searchVendors('pizza');

        expect(vendors.length, 2);
        expect(vendors[0].name, 'Pizza Palace');
        expect(vendors[1].name, 'Pizza Place');
      });

      test('returns empty list when no match', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(vendorMap(vendorId: 'v1', name: 'Pizza Palace')),
          ]),
        );

        final vendors = await vendorRepository.searchVendors('sushi');

        expect(vendors, isEmpty);
      });
    });

    group('updateVendor', () {
      test('calls Firestore updateDocument and caches', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final vendor = VendorModel(
          vendorId: 'v1',
          name: 'Updated Vendor',
          description: 'Updated',
          image: 'img',
          category: DeliveryType.food,
          lat: 0,
          lng: 0,
          address: 'addr',
          rating: 5,
          totalOrders: 0,
          isOpen: true,
          ownerId: 'owner1',
          createdAt: DateTime(2024),
        );

        await vendorRepository.updateVendor(vendor);

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.vendors,
              documentId: 'v1',
              data: vendor.toMap(),
            )).called(1);
        verify(() => mockCacheService.put<String>(any(), any(), any()))
            .called(1);
      });
    });
  });
}

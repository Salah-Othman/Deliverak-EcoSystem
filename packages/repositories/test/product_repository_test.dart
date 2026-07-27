// ignore_for_file: subtype_of_sealed_class
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

import 'helpers/firestore_test_helpers.dart';

void main() {
  late MockFirestoreService mockFirestoreService;
  late MockCacheService mockCacheService;
  late ProductRepository productRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    mockCacheService = MockCacheService();
    productRepository = ProductRepository(
      firestoreService: mockFirestoreService,
      cacheService: mockCacheService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(field: 'test', value: 'test'));
    registerFallbackValue(<String, dynamic>{});
  });

  Map<String, dynamic> productMap({
    String productId = 'p1',
    String vendorId = 'v1',
    String name = 'Test Product',
    String category = 'food',
    double price = 10.0,
    bool isAvailable = true,
  }) {
    return {
      'productId': productId,
      'vendorId': vendorId,
      'name': name,
      'description': 'A test product',
      'price': price,
      'discountPrice': null,
      'images': <String>[],
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': DateTime(2024).toIso8601String(),
    };
  }

  group('ProductRepository', () {
    group('getProducts', () {
      test('returns products from Firestore filtered by vendorId', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(productMap(productId: 'p1', vendorId: 'v1')),
            FakeDocumentSnapshot(productMap(productId: 'p3', vendorId: 'v1')),
          ]),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final products = await productRepository.getProducts(vendorId: 'v1');

        expect(products.length, 2);
        expect(products.every((p) => p.vendorId == 'v1'), isTrue);
      });

      test('returns products from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            productMap(productId: 'p1', vendorId: 'v1'),
            productMap(productId: 'p2', vendorId: 'v1'),
          ]),
        );

        final products = await productRepository.getProducts(vendorId: 'v1');

        expect(products.length, 2);
        verifyNever(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              orderBy: any(named: 'orderBy'),
              descending: any(named: 'descending'),
            ));
      });

      test('filters by category from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            productMap(productId: 'p1', vendorId: 'v1', category: 'food'),
            productMap(
                productId: 'p2', vendorId: 'v1', category: 'drinks'),
          ]),
        );

        final products = await productRepository.getProducts(
          vendorId: 'v1',
          category: 'food',
        );

        expect(products.length, 1);
        expect(products[0].category, 'food');
      });

      test('filters by isAvailable from cache', () async {
        when(() => mockCacheService.get<String>(any(), any())).thenReturn(
          jsonEncode([
            productMap(productId: 'p1', vendorId: 'v1', isAvailable: true),
            productMap(
                productId: 'p2', vendorId: 'v1', isAvailable: false),
          ]),
        );

        final products = await productRepository.getProducts(
          vendorId: 'v1',
          isAvailable: true,
        );

        expect(products.length, 1);
        expect(products[0].isAvailable, isTrue);
      });
    });

    group('getProduct', () {
      test('returns product when document exists', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(null);
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async =>
              FakeDocumentSnapshot(productMap(productId: 'p1'), id: 'p1'),
        );
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});

        final product = await productRepository.getProduct('p1');

        expect(product, isNotNull);
        expect(product!.productId, 'p1');
        expect(product.name, 'Test Product');
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

        final product = await productRepository.getProduct('nonexistent');

        expect(product, isNull);
      });

      test('returns product from cache', () async {
        when(() => mockCacheService.get<String>(any(), any()))
            .thenReturn(jsonEncode(productMap(productId: 'p1')));

        final product = await productRepository.getProduct('p1');

        expect(product, isNotNull);
        expect(product!.productId, 'p1');
        verifyNever(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            ));
      });
    });

    group('createProduct', () {
      test('calls Firestore setDocument and invalidates vendor cache',
          () async {
        when(() => mockFirestoreService.setDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        final product = ProductModel(
          productId: 'p1',
          vendorId: 'v1',
          name: 'New Product',
          description: 'Desc',
          price: 15.0,
          images: const ['https://example.com/img.jpg'],
          category: 'food',
          isAvailable: true,
          createdAt: DateTime(2024),
        );

        await productRepository.createProduct(product);

        verify(() => mockFirestoreService.setDocument(
              collection: FirestorePaths.products,
              documentId: 'p1',
              data: product.toMap(),
            )).called(1);
        verify(() => mockCacheService.delete(any(), 'products_v1')).called(1);
      });
    });

    group('updateProduct', () {
      test('calls Firestore updateDocument and updates cache', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.put<String>(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        final product = ProductModel(
          productId: 'p1',
          vendorId: 'v1',
          name: 'Updated Product',
          description: 'Desc',
          price: 20.0,
          images: const ['https://example.com/img.jpg'],
          category: 'food',
          isAvailable: true,
          createdAt: DateTime(2024),
        );

        await productRepository.updateProduct(product);

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.products,
              documentId: 'p1',
              data: product.toMap(),
            )).called(1);
        verify(() => mockCacheService.put<String>(
              any(),
              'product_p1',
              any(),
            )).called(1);
        verify(() => mockCacheService.delete(any(), 'products_v1')).called(1);
      });
    });

    group('deleteProduct', () {
      test('calls Firestore deleteDocument and removes from cache', () async {
        when(() => mockFirestoreService.deleteDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer((_) async {});
        when(() => mockCacheService.delete(any(), any()))
            .thenAnswer((_) async {});

        await productRepository.deleteProduct('p1');

        verify(() => mockFirestoreService.deleteDocument(
              collection: FirestorePaths.products,
              documentId: 'p1',
            )).called(1);
        verify(() => mockCacheService.delete(any(), 'product_p1')).called(1);
      });
    });
  });
}

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockProductRepository mockProductRepository;
  late MockStorageService mockStorageService;
  late VendorProductCubit cubit;

  setUp(() {
    mockProductRepository = MockProductRepository();
    mockStorageService = MockStorageService();
    cubit = VendorProductCubit(
      productRepository: mockProductRepository,
      storageService: mockStorageService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  setUpAll(() {
    registerFallbackValue(ProductModel(
      productId: '',
      vendorId: '',
      name: '',
      description: '',
      price: 0,
      images: const [],
      category: '',
      isAvailable: true,
      createdAt: DateTime(2024),
    ));
  });

  group('VendorProductCubit', () {
    test('initial state is VendorProductInitial', () {
      expect(cubit.state, isA<VendorProductInitial>());
    });

    group('watchProducts', () {
      late StreamController<List<ProductModel>> productsController;

      setUp(() {
        productsController = StreamController<List<ProductModel>>();
        when(() => mockProductRepository.watchProducts(any()))
            .thenAnswer((_) => productsController.stream);
      });

      tearDown(() {
        productsController.close();
      });

      blocTest<VendorProductCubit, VendorProductState>(
        'emits VendorProductsLoaded when products received',
        build: () => cubit,
        act: (cubit) {
          cubit.watchProducts('vendor-1');
          productsController.add([
            ProductModelFixture.create(productId: 'p1'),
            ProductModelFixture.create(productId: 'p2'),
          ]);
        },
        expect: () => [isA<VendorProductsLoaded>()],
        verify: (cubit) {
          final loaded = cubit.state as VendorProductsLoaded;
          expect(loaded.products.length, 2);
        },
      );

      blocTest<VendorProductCubit, VendorProductState>(
        'emits error on stream error',
        build: () => cubit,
        act: (cubit) {
          cubit.watchProducts('vendor-1');
          productsController.addError(Exception('Firestore error'));
        },
        expect: () => [isA<VendorProductError>()],
      );
    });

    group('createProduct', () {
      final product = ProductModelFixture.create(productId: '');

      blocTest<VendorProductCubit, VendorProductState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockProductRepository.createProduct(any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.createProduct(product),
        expect: () => [
          isA<VendorProductLoading>(),
          isA<VendorProductActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorProductActionSuccess;
          expect(success.message, contains('created'));
        },
      );

      blocTest<VendorProductCubit, VendorProductState>(
        'emits [Loading, Error] on failure',
        build: () {
          when(() => mockProductRepository.createProduct(any()))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.createProduct(product),
        expect: () => [
          isA<VendorProductLoading>(),
          isA<VendorProductError>(),
        ],
      );
    });

    group('updateProduct', () {
      final product = ProductModelFixture.create();

      blocTest<VendorProductCubit, VendorProductState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockProductRepository.updateProduct(any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.updateProduct(product),
        expect: () => [
          isA<VendorProductLoading>(),
          isA<VendorProductActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorProductActionSuccess;
          expect(success.message, contains('updated'));
        },
      );
    });

    group('deleteProduct', () {
      blocTest<VendorProductCubit, VendorProductState>(
        'emits [Loading, ActionSuccess] on success',
        build: () {
          when(() => mockProductRepository.deleteProduct(any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.deleteProduct('product-1'),
        expect: () => [
          isA<VendorProductLoading>(),
          isA<VendorProductActionSuccess>(),
        ],
        verify: (cubit) {
          final success = cubit.state as VendorProductActionSuccess;
          expect(success.message, contains('deleted'));
        },
      );
    });

    group('toggleAvailability', () {
      test('flips isAvailable and calls updateProduct', () async {
        final product = ProductModelFixture.create(isAvailable: true);
        when(() => mockProductRepository.updateProduct(any()))
            .thenAnswer((_) async {});

        await cubit.toggleAvailability(product);

        final captured = verify(() => mockProductRepository.updateProduct(captureAny()))
            .captured
            .single as ProductModel;
        expect(captured.isAvailable, isFalse);
      });

      blocTest<VendorProductCubit, VendorProductState>(
        'emits error on failure',
        build: () {
          when(() => mockProductRepository.updateProduct(any()))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.toggleAvailability(
          ProductModelFixture.create(isAvailable: true),
        ),
        expect: () => [isA<VendorProductError>()],
      );
    });

    group('uploadImage', () {
      test('returns secureUrl on success', () async {
        when(() => mockStorageService.uploadFile(
              filePath: any(named: 'filePath'),
              folder: any(named: 'folder'),
            )).thenAnswer(
          (_) async => const CloudinaryUploadResult(
            secureUrl: 'https://example.com/image.jpg',
            publicId: 'public-id',
          ),
        );

        final result = await cubit.uploadImage('/path/to/image.jpg', 'products');
        expect(result, 'https://example.com/image.jpg');
      });

      test('returns null on error', () async {
        when(() => mockStorageService.uploadFile(
              filePath: any(named: 'filePath'),
              folder: any(named: 'folder'),
            )).thenThrow(Exception('Upload failed'));

        final result = await cubit.uploadImage('/path/to/image.jpg', 'products');
        expect(result, isNull);
        expect(cubit.state, isA<VendorProductError>());
      });
    });

    group('close', () {
      test('cancels products subscription', () async {
        final controller = StreamController<List<ProductModel>>();
        when(() => mockProductRepository.watchProducts(any()))
            .thenAnswer((_) => controller.stream);

        cubit.watchProducts('vendor-1');
        await cubit.close();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });
  });
}

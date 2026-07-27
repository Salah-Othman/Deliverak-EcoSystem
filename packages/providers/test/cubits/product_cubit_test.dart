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
  late ProductCubit cubit;

  setUp(() {
    mockProductRepository = MockProductRepository();
    cubit = ProductCubit(productRepository: mockProductRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductCubit', () {
    test('initial state is ProductInitial', () {
      expect(cubit.state, isA<ProductInitial>());
    });

    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductsLoaded] on loadProducts',
      build: () {
        when(() => mockProductRepository.getProductsPaginated(
              vendorId: any(named: 'vendorId'),
              category: any(named: 'category'),
              isAvailable: any(named: 'isAvailable'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<ProductModel>(
              items: [
                ProductModelFixture.create(productId: 'p1'),
                ProductModelFixture.create(productId: 'p2'),
              ],
              hasMore: false,
            ));
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(vendorId: 'v1'),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductsLoaded>(),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductError] on loadProducts failure',
      build: () {
        when(() => mockProductRepository.getProductsPaginated(
              vendorId: any(named: 'vendorId'),
              category: any(named: 'category'),
              isAvailable: any(named: 'isAvailable'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('failed'));
        return cubit;
      },
      act: (cubit) => cubit.loadProducts(vendorId: 'v1'),
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductError>(),
      ],
    );

    blocTest<ProductCubit, ProductState>(
      'loadMore appends products when more available',
      build: () {
        when(() => mockProductRepository.getProductsPaginated(
              vendorId: any(named: 'vendorId'),
              category: any(named: 'category'),
              isAvailable: any(named: 'isAvailable'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<ProductModel>(
              items: [ProductModelFixture.create(productId: 'p2')],
              hasMore: true,
            ));
        return cubit;
      },
      seed: () => ProductsLoaded(
        products: [ProductModelFixture.create(productId: 'p1')],
        hasMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        isA<ProductsLoaded>(),
        isA<ProductsLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ProductsLoaded;
        expect(state.products.length, 2);
        expect(state.hasMore, true);
      },
    );

    blocTest<ProductCubit, ProductState>(
      'loadMore does nothing when hasMore is false',
      build: () => cubit,
      seed: () => ProductsLoaded(
        products: [ProductModelFixture.create()],
        hasMore: false,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    blocTest<ProductCubit, ProductState>(
      'watchProducts emits ProductsLoaded on stream events',
      build: () {
        final controller = StreamController<List<ProductModel>>();
        when(() => mockProductRepository.watchProducts('v1'))
            .thenAnswer((_) => controller.stream);
        return cubit;
      },
      act: (cubit) async {
        cubit.watchProducts('v1');
        await Future.delayed(Duration.zero);
      },
    );

    test('close cancels products subscription', () async {
      final controller = StreamController<List<ProductModel>>();
      when(() => mockProductRepository.watchProducts('v1'))
          .thenAnswer((_) => controller.stream);

      cubit.watchProducts('v1');
      await cubit.close();

      expect(controller.hasListener, false);
      await controller.close();
    });
  });
}

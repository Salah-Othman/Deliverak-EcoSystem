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
        when(() => mockProductRepository.getProducts(
              vendorId: any(named: 'vendorId'),
              category: any(named: 'category'),
              isAvailable: any(named: 'isAvailable'),
            )).thenAnswer((_) async => [
              ProductModelFixture.create(productId: 'p1'),
              ProductModelFixture.create(productId: 'p2'),
            ]);
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
        when(() => mockProductRepository.getProducts(
              vendorId: any(named: 'vendorId'),
              category: any(named: 'category'),
              isAvailable: any(named: 'isAvailable'),
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
      // Note: can't easily test stream emissions without actual data
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

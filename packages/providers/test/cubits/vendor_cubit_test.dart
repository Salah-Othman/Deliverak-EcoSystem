import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockVendorRepository mockVendorRepository;
  late VendorCubit cubit;

  setUp(() {
    mockVendorRepository = MockVendorRepository();
    cubit = VendorCubit(vendorRepository: mockVendorRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('VendorCubit', () {
    test('initial state is VendorInitial', () {
      expect(cubit.state, isA<VendorInitial>());
    });

    blocTest<VendorCubit, VendorState>(
      'emits [VendorLoading, VendorsLoaded] on loadVendors',
      build: () {
        when(() => mockVendorRepository.getVendors(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
            )).thenAnswer((_) async => [
              VendorModelFixture.create(vendorId: 'v1'),
              VendorModelFixture.create(vendorId: 'v2'),
            ]);
        return cubit;
      },
      act: (cubit) => cubit.loadVendors(),
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
      ],
    );

    blocTest<VendorCubit, VendorState>(
      'emits [VendorLoading, VendorError] on loadVendors failure',
      build: () {
        when(() => mockVendorRepository.getVendors(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
            )).thenThrow(Exception('failed'));
        return cubit;
      },
      act: (cubit) => cubit.loadVendors(),
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorError>(),
      ],
    );

    blocTest<VendorCubit, VendorState>(
      'emits [VendorLoading, VendorsLoaded] on searchVendors',
      build: () {
        when(() => mockVendorRepository.searchVendors(any()))
            .thenAnswer((_) async => [VendorModelFixture.create()]);
        return cubit;
      },
      act: (cubit) => cubit.searchVendors('pizza'),
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
      ],
    );

    blocTest<VendorCubit, VendorState>(
      'loadVendorsByCategory delegates to loadVendors',
      build: () {
        when(() => mockVendorRepository.getVendors(
              category: DeliveryType.food,
              isOpen: any(named: 'isOpen'),
            )).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadVendorsByCategory(DeliveryType.food),
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
      ],
    );
  });
}

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
    registerFallbackValue(DeliveryType.food);
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
        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<VendorModel>(
              items: [
                VendorModelFixture.create(vendorId: 'v1'),
                VendorModelFixture.create(vendorId: 'v2'),
              ],
              hasMore: false,
            ));
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
        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
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
        when(() => mockVendorRepository.getVendorsPaginated(
              category: DeliveryType.food,
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => const PaginatedResult<VendorModel>(
              items: [],
              hasMore: false,
            ));
        return cubit;
      },
      act: (cubit) => cubit.loadVendorsByCategory(DeliveryType.food),
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
      ],
    );

    blocTest<VendorCubit, VendorState>(
      'loadMore appends vendors when more available',
      build: () {
        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<VendorModel>(
              items: [VendorModelFixture.create(vendorId: 'page2')],
              hasMore: false,
            ));
        return cubit;
      },
      act: (cubit) async {
        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<VendorModel>(
              items: [VendorModelFixture.create(vendorId: 'v1')],
              hasMore: true,
            ));
        await cubit.loadVendors();

        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<VendorModel>(
              items: [VendorModelFixture.create(vendorId: 'v2')],
              hasMore: false,
            ));
        await cubit.loadMore();
      },
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
        isA<VendorsLoaded>(),
        isA<VendorsLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as VendorsLoaded;
        expect(state.vendors.length, 2);
        expect(state.hasMore, false);
      },
    );

    blocTest<VendorCubit, VendorState>(
      'loadMore does nothing when hasMore is false',
      build: () {
        when(() => mockVendorRepository.getVendorsPaginated(
              category: any(named: 'category'),
              isOpen: any(named: 'isOpen'),
              lastDocument: any(named: 'lastDocument'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => PaginatedResult<VendorModel>(
              items: [VendorModelFixture.create()],
              hasMore: false,
            ));
        return cubit;
      },
      act: (cubit) async {
        await cubit.loadVendors();
        await cubit.loadMore();
      },
      expect: () => [
        isA<VendorLoading>(),
        isA<VendorsLoaded>(),
      ],
    );
  });
}

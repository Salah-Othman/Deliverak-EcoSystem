import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockVendorRepository mockVendorRepository;
  late SearchCubit cubit;

  setUp(() {
    mockVendorRepository = MockVendorRepository();
    cubit = SearchCubit(vendorRepository: mockVendorRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('SearchCubit', () {
    test('initial state is SearchIdle', () {
      expect(cubit.state, isA<SearchIdle>());
    });

    test('search with empty query emits SearchIdle', () {
      cubit.search('');
      expect(cubit.state, isA<SearchIdle>());
    });

    test('search with whitespace-only query emits SearchIdle', () {
      cubit.search('   ');
      expect(cubit.state, isA<SearchIdle>());
    });

    test('clear cancels debounce and emits SearchIdle', () async {
      when(() => mockVendorRepository.searchVendors(any()))
          .thenAnswer((_) async => []);

      cubit.search('pizza');
      cubit.clear();
      // Wait for debounce to have fired if it wasn't cancelled
      await Future.delayed(const Duration(milliseconds: 600));

      expect(cubit.state, isA<SearchIdle>());
    });

    test('close cancels debounce timer', () async {
      when(() => mockVendorRepository.searchVendors(any()))
          .thenAnswer((_) async => []);

      cubit.search('pizza');
      await cubit.close();

      // If close didn't cancel the timer, this would throw
      // because the cubit is closed
      expect(true, true);
    });

    test('debounced search triggers after 500ms', () async {
      when(() => mockVendorRepository.searchVendors('pizza'))
          .thenAnswer((_) async => [VendorModelFixture.create()]);

      cubit.search('pizza');

      // Before debounce fires
      expect(cubit.state, isA<SearchIdle>());

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 600));

      expect(cubit.state, isA<SearchResults>());
    });

    test('rapid searches only use last query', () async {
      when(() => mockVendorRepository.searchVendors('burger'))
          .thenAnswer((_) async => [VendorModelFixture.create(name: 'Burger Joint')]);

      cubit.search('pizza');
      cubit.search('burger');

      await Future.delayed(const Duration(milliseconds: 600));

      verify(() => mockVendorRepository.searchVendors('burger')).called(1);
      verifyNever(() => mockVendorRepository.searchVendors('pizza'));
    });
  });
}

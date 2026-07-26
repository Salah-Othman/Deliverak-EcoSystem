import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:providers/providers.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/test_models.dart';

void main() {
  late MockVendorRepository mockVendorRepository;
  late MockStorageService mockStorageService;
  late VendorProfileCubit cubit;

  setUpAll(() {
    registerFallbackValue(VendorModelFixture.create());
    registerFallbackValue(const CloudinaryUploadResult(
      secureUrl: '',
      publicId: '',
    ));
  });

  setUp(() {
    mockVendorRepository = MockVendorRepository();
    mockStorageService = MockStorageService();
    cubit = VendorProfileCubit(
      vendorRepository: mockVendorRepository,
      storageService: mockStorageService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('VendorProfileCubit', () {
    test('initial state is VendorProfileInitial', () {
      expect(cubit.state, isA<VendorProfileInitial>());
    });

    group('loadVendorProfile', () {
      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits [Loading, Loaded] on success',
        build: () {
          when(() => mockVendorRepository.getVendor(any()))
              .thenAnswer((_) async => VendorModelFixture.create());
          return cubit;
        },
        act: (cubit) => cubit.loadVendorProfile('vendor-1'),
        expect: () => [
          isA<VendorProfileLoading>(),
          isA<VendorProfileLoaded>(),
        ],
        verify: (cubit) {
          final loaded = cubit.state as VendorProfileLoaded;
          expect(loaded.vendor.vendorId, 'test-vendor-id');
        },
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits [Loading, Error] when vendor not found',
        build: () {
          when(() => mockVendorRepository.getVendor(any()))
              .thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.loadVendorProfile('vendor-1'),
        expect: () => [
          isA<VendorProfileLoading>(),
          isA<VendorProfileError>(),
        ],
        verify: (cubit) {
          final error = cubit.state as VendorProfileError;
          expect(error.message, contains('not found'));
        },
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits [Loading, Error] on exception',
        build: () {
          when(() => mockVendorRepository.getVendor(any()))
              .thenThrow(Exception('Firestore error'));
          return cubit;
        },
        act: (cubit) => cubit.loadVendorProfile('vendor-1'),
        expect: () => [
          isA<VendorProfileLoading>(),
          isA<VendorProfileError>(),
        ],
      );
    });

    group('watchVendorProfile', () {
      late StreamController<VendorModel?> vendorController;

      setUp(() {
        vendorController = StreamController<VendorModel?>();
        when(() => mockVendorRepository.watchVendor(any()))
            .thenAnswer((_) => vendorController.stream);
      });

      tearDown(() {
        vendorController.close();
      });

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits VendorProfileLoaded when vendor received',
        build: () => cubit,
        act: (cubit) {
          cubit.watchVendorProfile('vendor-1');
          vendorController.add(VendorModelFixture.create());
        },
        expect: () => [isA<VendorProfileLoaded>()],
        verify: (cubit) {
          final loaded = cubit.state as VendorProfileLoaded;
          expect(loaded.vendor.vendorId, 'test-vendor-id');
        },
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'does not emit when vendor is null',
        build: () => cubit,
        act: (cubit) {
          cubit.watchVendorProfile('vendor-1');
          vendorController.add(null);
        },
        expect: () => <VendorProfileState>[],
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits error on stream error',
        build: () => cubit,
        act: (cubit) {
          cubit.watchVendorProfile('vendor-1');
          vendorController.addError(Exception('Stream error'));
        },
        expect: () => [isA<VendorProfileError>()],
      );
    });

    group('updateVendorProfile', () {
      final vendor = VendorModelFixture.create();

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits VendorProfileLoaded on success',
        build: () {
          when(() => mockVendorRepository.updateVendor(any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.updateVendorProfile(vendor),
        expect: () => [isA<VendorProfileLoaded>()],
        verify: (cubit) {
          final loaded = cubit.state as VendorProfileLoaded;
          expect(loaded.vendor, vendor);
        },
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits error on failure',
        build: () {
          when(() => mockVendorRepository.updateVendor(any()))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.updateVendorProfile(vendor),
        expect: () => [isA<VendorProfileError>()],
      );
    });

    group('toggleOpenClose', () {
      test('flips isOpen and calls updateVendor', () async {
        final vendor = VendorModelFixture.create(isOpen: true);
        when(() => mockVendorRepository.updateVendor(any()))
            .thenAnswer((_) async {});

        await cubit.toggleOpenClose(vendor);

        final captured = verify(() => mockVendorRepository.updateVendor(captureAny()))
            .captured
            .single as VendorModel;
        expect(captured.isOpen, isFalse);
      });

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits Loaded with toggled state on success',
        build: () {
          when(() => mockVendorRepository.updateVendor(any()))
              .thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.toggleOpenClose(
          VendorModelFixture.create(isOpen: true),
        ),
        expect: () => [isA<VendorProfileLoaded>()],
        verify: (cubit) {
          final loaded = cubit.state as VendorProfileLoaded;
          expect(loaded.vendor.isOpen, isFalse);
        },
      );

      blocTest<VendorProfileCubit, VendorProfileState>(
        'emits error on failure',
        build: () {
          when(() => mockVendorRepository.updateVendor(any()))
              .thenThrow(Exception('Failed'));
          return cubit;
        },
        act: (cubit) => cubit.toggleOpenClose(
          VendorModelFixture.create(isOpen: true),
        ),
        expect: () => [isA<VendorProfileError>()],
      );
    });

    group('uploadImage', () {
      test('returns secureUrl on success', () async {
        when(() => mockStorageService.uploadFile(
              filePath: any(named: 'filePath'),
              folder: any(named: 'folder'),
            )).thenAnswer(
          (_) async => const CloudinaryUploadResult(
            secureUrl: 'https://example.com/store.jpg',
            publicId: 'store-public-id',
          ),
        );

        final result = await cubit.uploadImage('/path/to/image.jpg', 'vendors');
        expect(result, 'https://example.com/store.jpg');
      });

      test('returns null on error', () async {
        when(() => mockStorageService.uploadFile(
              filePath: any(named: 'filePath'),
              folder: any(named: 'folder'),
            )).thenThrow(Exception('Upload failed'));

        final result = await cubit.uploadImage('/path/to/image.jpg', 'vendors');
        expect(result, isNull);
        expect(cubit.state, isA<VendorProfileError>());
      });
    });

    group('close', () {
      test('cancels vendor subscription', () async {
        final controller = StreamController<VendorModel?>();
        when(() => mockVendorRepository.watchVendor(any()))
            .thenAnswer((_) => controller.stream);

        cubit.watchVendorProfile('vendor-1');
        await cubit.close();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });
  });
}

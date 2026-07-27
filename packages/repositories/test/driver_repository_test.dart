// ignore_for_file: subtype_of_sealed_class
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:repositories/repositories.dart';

import 'helpers/firestore_test_helpers.dart';

void main() {
  late MockFirestoreService mockFirestoreService;
  late DriverRepository driverRepository;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    driverRepository = DriverRepository(
      firestoreService: mockFirestoreService,
    );
  });

  setUpAll(() {
    registerFallbackValue(const QueryCondition(field: 'test', value: 'test'));
  });

  Map<String, dynamic> driverMap({
    String driverId = 'd1',
    String userId = 'u1',
    String vehicleType = 'motorcycle',
    String vehicleNumber = 'ABC-123',
    String licenseNumber = 'LIC-001',
    bool isOnline = false,
    double currentLat = 0.0,
    double currentLng = 0.0,
  }) {
    return {
      'driverId': driverId,
      'userId': userId,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'isOnline': isOnline,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'rating': 0.0,
      'totalDeliveries': 0,
      'createdAt': DateTime(2024).toIso8601String(),
    };
  }

  group('DriverRepository', () {
    group('createDriver', () {
      test('creates driver with generated ID and calls setDocument', () async {
        when(() => mockFirestoreService.newDocumentId(
              collection: any(named: 'collection'),
            )).thenReturn('generated-driver-id');
        when(() => mockFirestoreService.setDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        final driver = await driverRepository.createDriver(
          userId: 'u1',
          vehicleType: 'motorcycle',
          vehicleNumber: 'ABC-123',
          licenseNumber: 'LIC-001',
        );

        expect(driver.userId, 'u1');
        expect(driver.vehicleType, 'motorcycle');
        expect(driver.vehicleNumber, 'ABC-123');
        expect(driver.licenseNumber, 'LIC-001');
        expect(driver.isOnline, isFalse);
        expect(driver.currentLat, 0.0);
        expect(driver.currentLng, 0.0);
        expect(driver.rating, 0.0);
        expect(driver.totalDeliveries, 0);
        verify(() => mockFirestoreService.setDocument(
              collection: FirestorePaths.drivers,
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).called(1);
      });
    });

    group('getDriver', () {
      test('returns driver when document exists', () async {
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async =>
              FakeDocumentSnapshot(driverMap(driverId: 'd1'), id: 'd1'),
        );

        final driver = await driverRepository.getDriver('d1');

        expect(driver, isNotNull);
        expect(driver!.driverId, 'd1');
        expect(driver.userId, 'u1');
      });

      test('returns null when document does not exist', () async {
        when(() => mockFirestoreService.getDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
            )).thenAnswer(
          (_) async => FakeDocumentSnapshot({}, exists: false),
        );

        final driver = await driverRepository.getDriver('nonexistent');

        expect(driver, isNull);
      });
    });

    group('getDriverByUserId', () {
      test('returns first driver matching userId', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(driverMap(driverId: 'd1', userId: 'u1'),
                id: 'd1'),
          ]),
        );

        final driver = await driverRepository.getDriverByUserId('u1');

        expect(driver, isNotNull);
        expect(driver!.userId, 'u1');
      });

      test('returns null when no driver matches userId', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([]),
        );

        final driver = await driverRepository.getDriverByUserId('nonexistent');

        expect(driver, isNull);
      });
    });

    group('updateLocation', () {
      test('calls Firestore updateDocument with lat and lng', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        await driverRepository.updateLocation('d1', 12.34, 56.78);

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.drivers,
              documentId: 'd1',
              data: {
                'currentLat': 12.34,
                'currentLng': 56.78,
              },
            )).called(1);
      });
    });

    group('updateOnlineStatus', () {
      test('calls Firestore updateDocument with isOnline', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        await driverRepository.updateOnlineStatus('d1', true);

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.drivers,
              documentId: 'd1',
              data: {
                'isOnline': true,
              },
            )).called(1);
      });
    });

    group('updateDriverProfile', () {
      test('calls Firestore updateDocument with non-null fields only', () async {
        when(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        await driverRepository.updateDriverProfile(
          driverId: 'd1',
          vehicleType: 'car',
          licenseNumber: 'LIC-999',
        );

        verify(() => mockFirestoreService.updateDocument(
              collection: FirestorePaths.drivers,
              documentId: 'd1',
              data: {
                'vehicleType': 'car',
                'licenseNumber': 'LIC-999',
              },
            )).called(1);
      });

      test('does not call Firestore when all fields are null', () async {
        await driverRepository.updateDriverProfile(driverId: 'd1');

        verifyNever(() => mockFirestoreService.updateDocument(
              collection: any(named: 'collection'),
              documentId: any(named: 'documentId'),
              data: any(named: 'data'),
            ));
      });
    });

    group('getAvailableDrivers', () {
      test('queries where isOnline == true', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([
            FakeDocumentSnapshot(
                driverMap(driverId: 'd1', isOnline: true), id: 'd1'),
            FakeDocumentSnapshot(
                driverMap(driverId: 'd2', isOnline: true), id: 'd2'),
          ]),
        );

        final drivers = await driverRepository.getAvailableDrivers();

        expect(drivers.length, 2);
        expect(drivers.every((d) => d.isOnline), isTrue);
      });

      test('returns empty list when no drivers online', () async {
        when(() => mockFirestoreService.getDocuments(
              collection: any(named: 'collection'),
              where: any(named: 'where'),
            )).thenAnswer(
          (_) async => FakeQuerySnapshot([]),
        );

        final drivers = await driverRepository.getAvailableDrivers();

        expect(drivers, isEmpty);
      });
    });
  });
}

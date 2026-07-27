import 'package:core/core.dart';

class DriverRepository implements IDriverRepository {
  final IFirestoreService _firestoreService;

  DriverRepository({
    required IFirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<DriverModel> createDriver({
    required String userId,
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    if (userId.trim().isEmpty) {
      throw const ValidationException(message: 'User ID is required');
    }
    if (vehicleType.trim().isEmpty) {
      throw const ValidationException(message: 'Vehicle type is required');
    }
    if (vehicleNumber.trim().isEmpty || vehicleNumber.trim().length > 20) {
      throw const ValidationException(message: 'Vehicle number must be 1–20 characters');
    }
    if (licenseNumber.trim().isEmpty || licenseNumber.trim().length > 30) {
      throw const ValidationException(message: 'License number must be 1–30 characters');
    }

    final now = DateTime.now();
    final driverId = _firestoreService.newDocumentId(
      collection: FirestorePaths.drivers,
    );

    final driver = DriverModel(
      driverId: driverId,
      userId: userId,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      isOnline: false,
      currentLat: 0,
      currentLng: 0,
      rating: 0,
      totalDeliveries: 0,
      createdAt: now,
    );

    await _firestoreService.setDocument(
      collection: FirestorePaths.drivers,
      documentId: driverId,
      data: driver.toMap(),
    );

    return driver;
  }

  @override
  Future<DriverModel?> getDriver(String driverId) async {
    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.drivers,
      documentId: driverId,
    );

    if (!doc.exists) return null;

    return DriverModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<DriverModel?> getDriverByUserId(String userId) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.drivers,
      where: [QueryCondition(field: 'userId', value: userId)],
    );

    if (docs.docs.isEmpty) return null;

    return DriverModel.fromMap(docs.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Stream<DriverModel?> watchDriver(String driverId) {
    return _firestoreService
        .watchDocument(
          collection: FirestorePaths.drivers,
          documentId: driverId,
        )
        .map((doc) {
      if (!doc.exists) return null;
      return DriverModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Future<void> updateLocation(String driverId, double lat, double lng) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.drivers,
      documentId: driverId,
      data: {
        'currentLat': lat,
        'currentLng': lng,
      },
    );
  }

  @override
  Future<void> updateOnlineStatus(String driverId, bool isOnline) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.drivers,
      documentId: driverId,
      data: {
        'isOnline': isOnline,
      },
    );
  }

  @override
  Future<void> updateDriverProfile({
    required String driverId,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
  }) async {
    if (vehicleNumber != null && (vehicleNumber.trim().isEmpty || vehicleNumber.trim().length > 20)) {
      throw const ValidationException(message: 'Vehicle number must be 1–20 characters');
    }
    if (licenseNumber != null && (licenseNumber.trim().isEmpty || licenseNumber.trim().length > 30)) {
      throw const ValidationException(message: 'License number must be 1–30 characters');
    }

    final updates = <String, dynamic>{};

    if (vehicleType != null) updates['vehicleType'] = vehicleType;
    if (vehicleNumber != null) updates['vehicleNumber'] = vehicleNumber;
    if (licenseNumber != null) updates['licenseNumber'] = licenseNumber;

    if (updates.isNotEmpty) {
      await _firestoreService.updateDocument(
        collection: FirestorePaths.drivers,
        documentId: driverId,
        data: updates,
      );
    }
  }

  @override
  Future<List<DriverModel>> getAvailableDrivers() async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.drivers,
      where: [QueryCondition(field: 'isOnline', value: true)],
    );

    return docs.docs
        .map((doc) => DriverModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

import 'package:core/core.dart';

class DriverRepository implements IDriverRepository {
  final IFirestoreService _firestoreService;

  DriverRepository({
    required IFirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

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

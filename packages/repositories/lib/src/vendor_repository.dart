import 'package:core/core.dart';

class VendorRepository implements IVendorRepository {
  final IFirestoreService _firestoreService;

  VendorRepository({required IFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<VendorModel>> getVendors({
    DeliveryType? category,
    bool? isOpen,
    int? limit,
  }) async {
    final query = await _firestoreService.getDocuments(
      collection: FirestorePaths.vendors,
      orderBy: 'rating',
      descending: true,
      limit: limit,
    );

    return query.docs
        .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((vendor) {
      if (category != null && vendor.category != category) return false;
      if (isOpen != null && vendor.isOpen != isOpen) return false;
      return true;
    }).toList();
  }

  @override
  Future<VendorModel?> getVendor(String vendorId) async {
    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.vendors,
      documentId: vendorId,
    );

    if (!doc.exists) return null;

    return VendorModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Stream<VendorModel?> watchVendor(String vendorId) {
    return _firestoreService
        .watchDocument(
          collection: FirestorePaths.vendors,
          documentId: vendorId,
        )
        .map((doc) {
      if (!doc.exists) return null;
      return VendorModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Future<List<VendorModel>> searchVendors(String query) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.vendors,
      orderBy: 'name',
    );

    return docs.docs
        .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((vendor) =>
            vendor.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> updateVendor(VendorModel vendor) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.vendors,
      documentId: vendor.vendorId,
      data: vendor.toMap(),
    );
  }
}

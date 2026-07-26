import 'dart:convert';

import 'package:core/core.dart';

const _kVendorsBox = 'vendors_box';

class VendorRepository implements IVendorRepository {
  final IFirestoreService _firestoreService;
  final ICacheService _cacheService;

  VendorRepository({
    required IFirestoreService firestoreService,
    required ICacheService cacheService,
  })  : _firestoreService = firestoreService,
        _cacheService = cacheService;

  String _cacheKey(DeliveryType? category, bool? isOpen) {
    return 'vendors_${category?.name ?? 'all'}_${isOpen ?? false}';
  }

  @override
  Future<List<VendorModel>> getVendors({
    DeliveryType? category,
    bool? isOpen,
    int? limit,
  }) async {
    final key = _cacheKey(category, isOpen);
    final cached = _cacheService.get<String>(_kVendorsBox, key);
    if (cached != null) {
      final list = (jsonDecode(cached) as List)
          .map((e) => VendorModel.fromMap(e as Map<String, dynamic>))
          .toList();
      if (limit != null && list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    }

    final query = await _firestoreService.getDocuments(
      collection: FirestorePaths.vendors,
      orderBy: 'rating',
      descending: true,
      limit: limit,
    );

    final vendors = query.docs
        .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((vendor) {
      if (category != null && vendor.category != category) return false;
      if (isOpen != null && vendor.isOpen != isOpen) return false;
      return true;
    }).toList();

    await _cacheService.put<String>(
      _kVendorsBox,
      key,
      jsonEncode(vendors.map((v) => v.toMap()).toList()),
    );

    return vendors;
  }

  @override
  Future<VendorModel?> getVendor(String vendorId) async {
    final cached = _cacheService.get<String>(_kVendorsBox, 'vendor_$vendorId');
    if (cached != null) {
      return VendorModel.fromMap(jsonDecode(cached) as Map<String, dynamic>);
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.vendors,
      documentId: vendorId,
    );

    if (!doc.exists) return null;

    final vendor = VendorModel.fromMap(doc.data() as Map<String, dynamic>);
    await _cacheService.put<String>(
      _kVendorsBox,
      'vendor_$vendorId',
      jsonEncode(vendor.toMap()),
    );
    return vendor;
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
      final vendor = VendorModel.fromMap(doc.data() as Map<String, dynamic>);
      _cacheService.put<String>(
        _kVendorsBox,
        'vendor_$vendorId',
        jsonEncode(vendor.toMap()),
      );
      return vendor;
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
    await _cacheService.put<String>(
      _kVendorsBox,
      'vendor_${vendor.vendorId}',
      jsonEncode(vendor.toMap()),
    );
  }
}

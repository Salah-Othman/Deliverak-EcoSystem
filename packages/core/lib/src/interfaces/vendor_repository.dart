import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/src/models/vendor_model.dart';
import 'package:core/src/models/paginated_result.dart';
import 'package:core/src/enums/delivery_type.dart';

abstract class IVendorRepository {
  Future<List<VendorModel>> getVendors({
    DeliveryType? category,
    bool? isOpen,
    int? limit,
  });

  Future<PaginatedResult<VendorModel>> getVendorsPaginated({
    DeliveryType? category,
    bool? isOpen,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });

  Future<VendorModel?> getVendor(String vendorId);

  Stream<VendorModel?> watchVendor(String vendorId);

  Future<List<VendorModel>> searchVendors(String query);

  Future<void> updateVendor(VendorModel vendor);
}

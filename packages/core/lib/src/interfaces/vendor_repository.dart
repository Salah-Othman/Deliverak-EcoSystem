import 'package:core/src/models/vendor_model.dart';
import 'package:core/src/enums/delivery_type.dart';

abstract class IVendorRepository {
  Future<List<VendorModel>> getVendors({
    DeliveryType? category,
    bool? isOpen,
    int? limit,
  });

  Future<VendorModel?> getVendor(String vendorId);

  Stream<VendorModel?> watchVendor(String vendorId);

  Future<List<VendorModel>> searchVendors(String query);

  Future<void> updateVendor(VendorModel vendor);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/src/models/product_model.dart';
import 'package:core/src/models/paginated_result.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  });

  Future<PaginatedResult<ProductModel>> getProductsPaginated({
    required String vendorId,
    String? category,
    bool? isAvailable,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });

  Future<ProductModel?> getProduct(String productId);

  Future<void> createProduct(ProductModel product);

  Future<void> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);

  Stream<List<ProductModel>> watchProducts(String vendorId);
}

import 'package:core/src/models/product_model.dart';

abstract class IProductRepository {
  Future<List<ProductModel>> getProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  });

  Future<ProductModel?> getProduct(String productId);

  Future<void> createProduct(ProductModel product);

  Future<void> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);

  Stream<List<ProductModel>> watchProducts(String vendorId);
}

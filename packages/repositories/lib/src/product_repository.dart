import 'package:core/core.dart';

class ProductRepository implements IProductRepository {
  final IFirestoreService _firestoreService;

  ProductRepository({required IFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<ProductModel>> getProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  }) async {
    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.products,
      orderBy: 'createdAt',
      descending: true,
    );

    return docs.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((product) {
      if (product.vendorId != vendorId) return false;
      if (category != null && product.category != category) return false;
      if (isAvailable != null && product.isAvailable != isAvailable) return false;
      return true;
    }).toList();
  }

  @override
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.products,
      documentId: productId,
    );

    if (!doc.exists) return null;

    return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _firestoreService.setDocument(
      collection: FirestorePaths.products,
      documentId: product.productId,
      data: product.toMap(),
    );
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.products,
      documentId: product.productId,
      data: product.toMap(),
    );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteDocument(
      collection: FirestorePaths.products,
      documentId: productId,
    );
  }

  @override
  Stream<List<ProductModel>> watchProducts(String vendorId) {
    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.products,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((product) => product.vendorId == vendorId)
            .toList());
  }
}

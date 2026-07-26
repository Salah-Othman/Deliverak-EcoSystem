import 'dart:convert';

import 'package:core/core.dart';

const _kProductsBox = 'products_box';

class ProductRepository implements IProductRepository {
  final IFirestoreService _firestoreService;
  final ICacheService _cacheService;

  ProductRepository({
    required IFirestoreService firestoreService,
    required ICacheService cacheService,
  })  : _firestoreService = firestoreService,
        _cacheService = cacheService;

  @override
  Future<List<ProductModel>> getProducts({
    required String vendorId,
    String? category,
    bool? isAvailable,
  }) async {
    final cacheKey = 'products_$vendorId';
    final cached = _cacheService.get<String>(_kProductsBox, cacheKey);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => ProductModel.fromMap(e as Map<String, dynamic>))
          .where((product) {
        if (category != null && product.category != category) return false;
        if (isAvailable != null && product.isAvailable != isAvailable) {
          return false;
        }
        return true;
      }).toList();
    }

    final docs = await _firestoreService.getDocuments(
      collection: FirestorePaths.products,
      orderBy: 'createdAt',
      descending: true,
    );

    final products = docs.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((product) {
      if (product.vendorId != vendorId) return false;
      if (category != null && product.category != category) return false;
      if (isAvailable != null && product.isAvailable != isAvailable) return false;
      return true;
    }).toList();

    await _cacheService.put<String>(
      _kProductsBox,
      cacheKey,
      jsonEncode(products.map((p) => p.toMap()).toList()),
    );

    return products;
  }

  @override
  Future<ProductModel?> getProduct(String productId) async {
    final cached =
        _cacheService.get<String>(_kProductsBox, 'product_$productId');
    if (cached != null) {
      return ProductModel.fromMap(jsonDecode(cached) as Map<String, dynamic>);
    }

    final doc = await _firestoreService.getDocument(
      collection: FirestorePaths.products,
      documentId: productId,
    );

    if (!doc.exists) return null;

    final product = ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    await _cacheService.put<String>(
      _kProductsBox,
      'product_$productId',
      jsonEncode(product.toMap()),
    );
    return product;
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _firestoreService.setDocument(
      collection: FirestorePaths.products,
      documentId: product.productId,
      data: product.toMap(),
    );
    await _cacheService.delete(_kProductsBox, 'products_${product.vendorId}');
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestoreService.updateDocument(
      collection: FirestorePaths.products,
      documentId: product.productId,
      data: product.toMap(),
    );
    await _cacheService.put<String>(
      _kProductsBox,
      'product_${product.productId}',
      jsonEncode(product.toMap()),
    );
    await _cacheService.delete(_kProductsBox, 'products_${product.vendorId}');
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteDocument(
      collection: FirestorePaths.products,
      documentId: productId,
    );
    await _cacheService.delete(_kProductsBox, 'product_$productId');
  }

  @override
  Stream<List<ProductModel>> watchProducts(String vendorId) {
    return _firestoreService
        .watchDocuments(
          collection: FirestorePaths.products,
          orderBy: 'createdAt',
          descending: true,
        )
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) =>
              ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((product) => product.vendorId == vendorId)
          .toList();

      _cacheService.put<String>(
        _kProductsBox,
        'products_$vendorId',
        jsonEncode(products.map((p) => p.toMap()).toList()),
      );

      return products;
    });
  }
}

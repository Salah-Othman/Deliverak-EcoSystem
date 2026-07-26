import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import '../helpers/test_models.dart';

void main() {
  group('ProductModel', () {
    test('fromMap creates valid model', () {
      final map = {
        'productId': 'p-1',
        'vendorId': 'v-1',
        'name': 'Burger',
        'description': 'Tasty burger',
        'price': 9.99,
        'discountPrice': 7.99,
        'images': ['img1.jpg', 'img2.jpg'],
        'category': 'Burgers',
        'isAvailable': true,
        'createdAt': DateTime(2024).toIso8601String(),
      };

      final product = ProductModel.fromMap(map);

      expect(product.productId, 'p-1');
      expect(product.price, 9.99);
      expect(product.discountPrice, 7.99);
      expect(product.images.length, 2);
    });

    test('fromMap handles missing optional fields', () {
      final product = ProductModel.fromMap({});

      expect(product.productId, '');
      expect(product.price, 0.0);
      expect(product.discountPrice, null);
      expect(product.images, isEmpty);
      expect(product.isAvailable, true);
    });

    test('toMap round-trips through fromMap', () {
      final product = ProductModelFixture.create();
      final roundTripped = ProductModel.fromMap(product.toMap());

      expect(roundTripped.productId, product.productId);
      expect(roundTripped.name, product.name);
      expect(roundTripped.price, product.price);
      expect(roundTripped.images, product.images);
    });

    test('copyWith changes specified fields', () {
      final product = ProductModelFixture.create(price: 9.99);
      final updated = product.copyWith(price: 12.99, isAvailable: false);

      expect(updated.price, 12.99);
      expect(updated.isAvailable, false);
      expect(updated.productId, product.productId);
    });
  });
}

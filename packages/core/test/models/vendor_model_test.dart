import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import '../helpers/test_models.dart';

void main() {
  group('VendorModel', () {
    test('fromMap creates valid model with all fields', () {
      final now = DateTime(2024);
      final map = {
        'vendorId': 'v-1',
        'name': 'Pizza Place',
        'description': 'Best pizza',
        'image': 'https://img.jpg',
        'category': 'grocery',
        'lat': 40.71,
        'lng': -74.00,
        'address': '123 Main',
        'rating': 4.8,
        'totalOrders': 500,
        'isOpen': true,
        'ownerId': 'owner-1',
        'createdAt': now.toIso8601String(),
      };

      final vendor = VendorModel.fromMap(map);

      expect(vendor.vendorId, 'v-1');
      expect(vendor.name, 'Pizza Place');
      expect(vendor.category, DeliveryType.grocery);
      expect(vendor.rating, 4.8);
      expect(vendor.totalOrders, 500);
      expect(vendor.isOpen, true);
    });

    test('fromMap handles missing fields with defaults', () {
      final vendor = VendorModel.fromMap({});

      expect(vendor.vendorId, '');
      expect(vendor.name, '');
      expect(vendor.category, DeliveryType.food);
      expect(vendor.lat, 0.0);
      expect(vendor.isOpen, false);
    });

    test('toMap round-trips through fromMap', () {
      final vendor = VendorModelFixture.create();
      final roundTripped = VendorModel.fromMap(vendor.toMap());

      expect(roundTripped.vendorId, vendor.vendorId);
      expect(roundTripped.name, vendor.name);
      expect(roundTripped.category, vendor.category);
      expect(roundTripped.rating, vendor.rating);
    });

    test('copyWith changes specified fields', () {
      final vendor = VendorModelFixture.create(name: 'Old');
      final updated = vendor.copyWith(name: 'New', isOpen: false);

      expect(updated.name, 'New');
      expect(updated.isOpen, false);
      expect(updated.vendorId, vendor.vendorId);
    });

    test('Equatable works correctly', () {
      final v1 = VendorModelFixture.create();
      final v2 = VendorModelFixture.create();
      expect(v1, equals(v2));
    });
  });
}

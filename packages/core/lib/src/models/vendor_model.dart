import 'package:equatable/equatable.dart';

import '../enums/delivery_type.dart';

class VendorModel extends Equatable {
  final String vendorId;
  final String name;
  final String description;
  final String image;
  final DeliveryType category;
  final double lat;
  final double lng;
  final String address;
  final double rating;
  final int totalOrders;
  final bool isOpen;
  final String ownerId;
  final DateTime createdAt;

  const VendorModel({
    required this.vendorId,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.lat,
    required this.lng,
    required this.address,
    required this.rating,
    required this.totalOrders,
    required this.isOpen,
    required this.ownerId,
    required this.createdAt,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
      category: DeliveryType.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DeliveryType.food,
      ),
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalOrders: map['totalOrders'] as int? ?? 0,
      isOpen: map['isOpen'] as bool? ?? false,
      ownerId: map['ownerId'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'image': image,
      'category': category.name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'rating': rating,
      'totalOrders': totalOrders,
      'isOpen': isOpen,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  VendorModel copyWith({
    String? name,
    String? description,
    String? image,
    DeliveryType? category,
    double? lat,
    double? lng,
    String? address,
    double? rating,
    int? totalOrders,
    bool? isOpen,
  }) {
    return VendorModel(
      vendorId: vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isOpen: isOpen ?? this.isOpen,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [vendorId, name, description, image, category, lat, lng, address, rating, totalOrders, isOpen, ownerId, createdAt];
}

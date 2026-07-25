import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String productId;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;

  const ProductModel({
    required this.productId,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.category,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] as List<dynamic>? ?? []),
      category: map['category'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? category,
    bool? isAvailable,
  }) {
    return ProductModel(
      productId: productId,
      vendorId: vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [productId, vendorId, name, description, price, discountPrice, images, category, isAvailable, createdAt];
}

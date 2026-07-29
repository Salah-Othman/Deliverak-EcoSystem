import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/app_exception.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

DateTime _productDateTimeFromJson(String value) => DateTime.parse(value);
String _productDateTimeToJson(DateTime value) => value.toIso8601String();

@Freezed(copyWith: false)
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    @Default('') String productId,
    @Default('') String vendorId,
    @Default('') String name,
    @Default('') String description,
    @Default(0.0) double price,
    double? discountPrice,
    @Default([]) List<String> images,
    @Default('') String category,
    @Default(true) bool isAvailable,
    @JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson)
    required DateTime createdAt,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel.fromJson({
      'createdAt': DateTime.now().toIso8601String(),
      ...map,
    });
  }

  Map<String, dynamic> toMap() => toJson();

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

  void validate() {
    if (productId.trim().isEmpty) {
      throw const ValidationException(message: 'Product ID is required');
    }
    if (vendorId.trim().isEmpty) {
      throw const ValidationException(message: 'Vendor ID is required');
    }
    if (name.trim().isEmpty || name.trim().length > 100) {
      throw const ValidationException(message: 'Product name must be 1–100 characters');
    }
    if (description.trim().length > 1000) {
      throw const ValidationException(message: 'Description must be 1000 characters or less');
    }
    if (price < 0 || price > 999999) {
      throw const ValidationException(message: 'Price must be between 0 and 999,999');
    }
    if (discountPrice != null && (discountPrice! < 0 || discountPrice! > price)) {
      throw const ValidationException(message: 'Discount price must be between 0 and the original price');
    }
    if (images.isEmpty) {
      throw const ValidationException(message: 'At least one product image is required');
    }
    if (category.trim().isEmpty) {
      throw const ValidationException(message: 'Product category is required');
    }
  }
}

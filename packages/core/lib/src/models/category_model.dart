import 'package:equatable/equatable.dart';

import '../enums/delivery_type.dart';
import '../exceptions/app_exception.dart';

class CategoryModel extends Equatable {
  final String categoryId;
  final String name;
  final String image;
  final DeliveryType type;
  final int sortOrder;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.image,
    required this.type,
    required this.sortOrder,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['categoryId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      image: map['image'] as String? ?? '',
      type: DeliveryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DeliveryType.food,
      ),
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'image': image,
      'type': type.name,
      'sortOrder': sortOrder,
    };
  }

  @override
  List<Object?> get props => [categoryId, name, image, type, sortOrder];

  void validate() {
    if (categoryId.trim().isEmpty) {
      throw const ValidationException(message: 'Category ID is required');
    }
    if (name.trim().isEmpty || name.trim().length > 50) {
      throw const ValidationException(message: 'Category name must be 1–50 characters');
    }
    if (image.trim().isEmpty) {
      throw const ValidationException(message: 'Category image is required');
    }
  }
}

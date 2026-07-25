import 'package:equatable/equatable.dart';

import '../enums/delivery_type.dart';

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
}

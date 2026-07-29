import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/delivery_type.dart';
import '../exceptions/app_exception.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String categoryId,
    required String name,
    required String image,
    required DeliveryType type,
    required int sortOrder,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  static CategoryModel fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromJson(map);

  Map<String, dynamic> toMap() => toJson();

  void validate() {
    if (categoryId.trim().isEmpty) {
      throw const ValidationException(message: 'Category ID is required');
    }
    if (name.trim().isEmpty || name.trim().length > 50) {
      throw const ValidationException(
        message: 'Category name must be 1–50 characters',
      );
    }
    if (image.trim().isEmpty) {
      throw const ValidationException(message: 'Category image is required');
    }
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductModel {

 String get productId; String get vendorId; String get name; String get description; double get price; double? get discountPrice; List<String> get images; String get category; bool get isAvailable;@JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson) DateTime get createdAt;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.discountPrice, discountPrice) || other.discountPrice == discountPrice)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.category, category) || other.category == category)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,vendorId,name,description,price,discountPrice,const DeepCollectionEquality().hash(images),category,isAvailable,createdAt);

@override
String toString() {
  return 'ProductModel(productId: $productId, vendorId: $vendorId, name: $name, description: $description, price: $price, discountPrice: $discountPrice, images: $images, category: $category, isAvailable: $isAvailable, createdAt: $createdAt)';
}


}




/// Adds pattern-matching-related methods to [ProductModel].
extension ProductModelPatterns on ProductModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String vendorId,  String name,  String description,  double price,  double? discountPrice,  List<String> images,  String category,  bool isAvailable, @JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.productId,_that.vendorId,_that.name,_that.description,_that.price,_that.discountPrice,_that.images,_that.category,_that.isAvailable,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String vendorId,  String name,  String description,  double price,  double? discountPrice,  List<String> images,  String category,  bool isAvailable, @JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that.productId,_that.vendorId,_that.name,_that.description,_that.price,_that.discountPrice,_that.images,_that.category,_that.isAvailable,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String vendorId,  String name,  String description,  double price,  double? discountPrice,  List<String> images,  String category,  bool isAvailable, @JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.productId,_that.vendorId,_that.name,_that.description,_that.price,_that.discountPrice,_that.images,_that.category,_that.isAvailable,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel extends ProductModel {
  const _ProductModel({this.productId = '', this.vendorId = '', this.name = '', this.description = '', this.price = 0.0, this.discountPrice, final  List<String> images = const [], this.category = '', this.isAvailable = true, @JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson) required this.createdAt}): _images = images,super._();
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override@JsonKey() final  String productId;
@override@JsonKey() final  String vendorId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  double price;
@override final  double? discountPrice;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey() final  String category;
@override@JsonKey() final  bool isAvailable;
@override@JsonKey(toJson: _productDateTimeToJson, fromJson: _productDateTimeFromJson) final  DateTime createdAt;


@override
Map<String, dynamic> toJson() {
  return _$ProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.discountPrice, discountPrice) || other.discountPrice == discountPrice)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.category, category) || other.category == category)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,vendorId,name,description,price,discountPrice,const DeepCollectionEquality().hash(_images),category,isAvailable,createdAt);

@override
String toString() {
  return 'ProductModel(productId: $productId, vendorId: $vendorId, name: $name, description: $description, price: $price, discountPrice: $discountPrice, images: $images, category: $category, isAvailable: $isAvailable, createdAt: $createdAt)';
}


}




// dart format on

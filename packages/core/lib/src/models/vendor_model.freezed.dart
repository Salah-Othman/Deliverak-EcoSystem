// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorModel {

 String get vendorId; String get name; String get description; String get image;@JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson) DeliveryType get category; double get lat; double get lng; String get address; double get rating; int get totalOrders; bool get isOpen; String get ownerId;@JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson) DateTime get createdAt;

  /// Serializes this VendorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorModel&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.category, category) || other.category == category)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.address, address) || other.address == address)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorId,name,description,image,category,lat,lng,address,rating,totalOrders,isOpen,ownerId,createdAt);

@override
String toString() {
  return 'VendorModel(vendorId: $vendorId, name: $name, description: $description, image: $image, category: $category, lat: $lat, lng: $lng, address: $address, rating: $rating, totalOrders: $totalOrders, isOpen: $isOpen, ownerId: $ownerId, createdAt: $createdAt)';
}


}




/// Adds pattern-matching-related methods to [VendorModel].
extension VendorModelPatterns on VendorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorModel value)  $default,){
final _that = this;
switch (_that) {
case _VendorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorModel value)?  $default,){
final _that = this;
switch (_that) {
case _VendorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vendorId,  String name,  String description,  String image, @JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson)  DeliveryType category,  double lat,  double lng,  String address,  double rating,  int totalOrders,  bool isOpen,  String ownerId, @JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorModel() when $default != null:
return $default(_that.vendorId,_that.name,_that.description,_that.image,_that.category,_that.lat,_that.lng,_that.address,_that.rating,_that.totalOrders,_that.isOpen,_that.ownerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vendorId,  String name,  String description,  String image, @JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson)  DeliveryType category,  double lat,  double lng,  String address,  double rating,  int totalOrders,  bool isOpen,  String ownerId, @JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _VendorModel():
return $default(_that.vendorId,_that.name,_that.description,_that.image,_that.category,_that.lat,_that.lng,_that.address,_that.rating,_that.totalOrders,_that.isOpen,_that.ownerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vendorId,  String name,  String description,  String image, @JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson)  DeliveryType category,  double lat,  double lng,  String address,  double rating,  int totalOrders,  bool isOpen,  String ownerId, @JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VendorModel() when $default != null:
return $default(_that.vendorId,_that.name,_that.description,_that.image,_that.category,_that.lat,_that.lng,_that.address,_that.rating,_that.totalOrders,_that.isOpen,_that.ownerId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorModel extends VendorModel {
  const _VendorModel({this.vendorId = '', this.name = '', this.description = '', this.image = '', @JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson) this.category = DeliveryType.food, this.lat = 0.0, this.lng = 0.0, this.address = '', this.rating = 0.0, this.totalOrders = 0, this.isOpen = false, this.ownerId = '', @JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson) required this.createdAt}): super._();
  factory _VendorModel.fromJson(Map<String, dynamic> json) => _$VendorModelFromJson(json);

@override@JsonKey() final  String vendorId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String image;
@override@JsonKey(toJson: _deliveryTypeToJson, fromJson: _deliveryTypeFromJson) final  DeliveryType category;
@override@JsonKey() final  double lat;
@override@JsonKey() final  double lng;
@override@JsonKey() final  String address;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalOrders;
@override@JsonKey() final  bool isOpen;
@override@JsonKey() final  String ownerId;
@override@JsonKey(toJson: _vendorDateTimeToJson, fromJson: _vendorDateTimeFromJson) final  DateTime createdAt;


@override
Map<String, dynamic> toJson() {
  return _$VendorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorModel&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.category, category) || other.category == category)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.address, address) || other.address == address)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorId,name,description,image,category,lat,lng,address,rating,totalOrders,isOpen,ownerId,createdAt);

@override
String toString() {
  return 'VendorModel(vendorId: $vendorId, name: $name, description: $description, image: $image, category: $category, lat: $lat, lng: $lng, address: $address, rating: $rating, totalOrders: $totalOrders, isOpen: $isOpen, ownerId: $ownerId, createdAt: $createdAt)';
}


}




// dart format on

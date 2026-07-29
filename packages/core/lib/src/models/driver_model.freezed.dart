// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverModel {

 String get driverId; String get userId; String get vehicleType; String get vehicleNumber; String get licenseNumber; bool get isOnline; double get currentLat; double get currentLng; double get rating; int get totalDeliveries;@JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson) DateTime get createdAt;
/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this as DriverModel, _$identity);

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,userId,vehicleType,vehicleNumber,licenseNumber,isOnline,currentLat,currentLng,rating,totalDeliveries,createdAt);

@override
String toString() {
  return 'DriverModel(driverId: $driverId, userId: $userId, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, licenseNumber: $licenseNumber, isOnline: $isOnline, currentLat: $currentLat, currentLng: $currentLng, rating: $rating, totalDeliveries: $totalDeliveries, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res>  {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@useResult
$Res call({
 String driverId, String userId, String vehicleType, String vehicleNumber, String licenseNumber, bool isOnline, double currentLat, double currentLng, double rating, int totalDeliveries,@JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson) DateTime createdAt
});




}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? userId = null,Object? vehicleType = null,Object? vehicleNumber = null,Object? licenseNumber = null,Object? isOnline = null,Object? currentLat = null,Object? currentLng = null,Object? rating = null,Object? totalDeliveries = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,licenseNumber: null == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,currentLat: null == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double,currentLng: null == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverModel].
extension DriverModelPatterns on DriverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  String userId,  String vehicleType,  String vehicleNumber,  String licenseNumber,  bool isOnline,  double currentLat,  double currentLng,  double rating,  int totalDeliveries, @JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson)  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.driverId,_that.userId,_that.vehicleType,_that.vehicleNumber,_that.licenseNumber,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.totalDeliveries,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  String userId,  String vehicleType,  String vehicleNumber,  String licenseNumber,  bool isOnline,  double currentLat,  double currentLng,  double rating,  int totalDeliveries, @JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson)  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DriverModel():
return $default(_that.driverId,_that.userId,_that.vehicleType,_that.vehicleNumber,_that.licenseNumber,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.totalDeliveries,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  String userId,  String vehicleType,  String vehicleNumber,  String licenseNumber,  bool isOnline,  double currentLat,  double currentLng,  double rating,  int totalDeliveries, @JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson)  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.driverId,_that.userId,_that.vehicleType,_that.vehicleNumber,_that.licenseNumber,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.totalDeliveries,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverModel extends DriverModel {
  const _DriverModel({this.driverId = '', this.userId = '', this.vehicleType = '', this.vehicleNumber = '', this.licenseNumber = '', this.isOnline = false, this.currentLat = 0.0, this.currentLng = 0.0, this.rating = 0.0, this.totalDeliveries = 0, @JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson) required this.createdAt}): super._();
  factory _DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

@override@JsonKey() final  String driverId;
@override@JsonKey() final  String userId;
@override@JsonKey() final  String vehicleType;
@override@JsonKey() final  String vehicleNumber;
@override@JsonKey() final  String licenseNumber;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  double currentLat;
@override@JsonKey() final  double currentLng;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalDeliveries;
@override@JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson) final  DateTime createdAt;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverModelCopyWith<_DriverModel> get copyWith => __$DriverModelCopyWithImpl<_DriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverModel&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,userId,vehicleType,vehicleNumber,licenseNumber,isOnline,currentLat,currentLng,rating,totalDeliveries,createdAt);

@override
String toString() {
  return 'DriverModel(driverId: $driverId, userId: $userId, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, licenseNumber: $licenseNumber, isOnline: $isOnline, currentLat: $currentLat, currentLng: $currentLng, rating: $rating, totalDeliveries: $totalDeliveries, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DriverModelCopyWith<$Res> implements $DriverModelCopyWith<$Res> {
  factory _$DriverModelCopyWith(_DriverModel value, $Res Function(_DriverModel) _then) = __$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String driverId, String userId, String vehicleType, String vehicleNumber, String licenseNumber, bool isOnline, double currentLat, double currentLng, double rating, int totalDeliveries,@JsonKey(toJson: _driverDateTimeToJson, fromJson: _driverDateTimeFromJson) DateTime createdAt
});




}
/// @nodoc
class __$DriverModelCopyWithImpl<$Res>
    implements _$DriverModelCopyWith<$Res> {
  __$DriverModelCopyWithImpl(this._self, this._then);

  final _DriverModel _self;
  final $Res Function(_DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? userId = null,Object? vehicleType = null,Object? vehicleNumber = null,Object? licenseNumber = null,Object? isOnline = null,Object? currentLat = null,Object? currentLng = null,Object? rating = null,Object? totalDeliveries = null,Object? createdAt = null,}) {
  return _then(_DriverModel(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,licenseNumber: null == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,currentLat: null == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double,currentLng: null == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

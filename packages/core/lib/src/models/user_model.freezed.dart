// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get uid; String get name; String get email; String get phone;@JsonKey(toJson: _roleToJson, fromJson: _roleFromJson) UserRole get role; String? get fcmToken; String? get profileImage;@JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) DateTime get createdAt;@JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) DateTime get updatedAt;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,email,phone,role,fcmToken,profileImage,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(uid: $uid, name: $name, email: $email, phone: $phone, role: $role, fcmToken: $fcmToken, profileImage: $profileImage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}




/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String name,  String email,  String phone, @JsonKey(toJson: _roleToJson, fromJson: _roleFromJson)  UserRole role,  String? fcmToken,  String? profileImage, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime createdAt, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.role,_that.fcmToken,_that.profileImage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String name,  String email,  String phone, @JsonKey(toJson: _roleToJson, fromJson: _roleFromJson)  UserRole role,  String? fcmToken,  String? profileImage, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime createdAt, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.role,_that.fcmToken,_that.profileImage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String name,  String email,  String phone, @JsonKey(toJson: _roleToJson, fromJson: _roleFromJson)  UserRole role,  String? fcmToken,  String? profileImage, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime createdAt, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.name,_that.email,_that.phone,_that.role,_that.fcmToken,_that.profileImage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({this.uid = '', this.name = '', this.email = '', this.phone = '', @JsonKey(toJson: _roleToJson, fromJson: _roleFromJson) this.role = UserRole.customer, this.fcmToken, this.profileImage, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) required this.createdAt, @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) required this.updatedAt}): super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey() final  String uid;
@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override@JsonKey() final  String phone;
@override@JsonKey(toJson: _roleToJson, fromJson: _roleFromJson) final  UserRole role;
@override final  String? fcmToken;
@override final  String? profileImage;
@override@JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) final  DateTime createdAt;
@override@JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson) final  DateTime updatedAt;


@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.profileImage, profileImage) || other.profileImage == profileImage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,email,phone,role,fcmToken,profileImage,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(uid: $uid, name: $name, email: $email, phone: $phone, role: $role, fcmToken: $fcmToken, profileImage: $profileImage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}




// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloudinary_upload_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudinaryUploadResult {

 String get secureUrl; String get publicId; int? get width; int? get height; String? get format;
/// Create a copy of CloudinaryUploadResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudinaryUploadResultCopyWith<CloudinaryUploadResult> get copyWith => _$CloudinaryUploadResultCopyWithImpl<CloudinaryUploadResult>(this as CloudinaryUploadResult, _$identity);

  /// Serializes this CloudinaryUploadResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudinaryUploadResult&&(identical(other.secureUrl, secureUrl) || other.secureUrl == secureUrl)&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureUrl,publicId,width,height,format);

@override
String toString() {
  return 'CloudinaryUploadResult(secureUrl: $secureUrl, publicId: $publicId, width: $width, height: $height, format: $format)';
}


}

/// @nodoc
abstract mixin class $CloudinaryUploadResultCopyWith<$Res>  {
  factory $CloudinaryUploadResultCopyWith(CloudinaryUploadResult value, $Res Function(CloudinaryUploadResult) _then) = _$CloudinaryUploadResultCopyWithImpl;
@useResult
$Res call({
 String secureUrl, String publicId, int? width, int? height, String? format
});




}
/// @nodoc
class _$CloudinaryUploadResultCopyWithImpl<$Res>
    implements $CloudinaryUploadResultCopyWith<$Res> {
  _$CloudinaryUploadResultCopyWithImpl(this._self, this._then);

  final CloudinaryUploadResult _self;
  final $Res Function(CloudinaryUploadResult) _then;

/// Create a copy of CloudinaryUploadResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secureUrl = null,Object? publicId = null,Object? width = freezed,Object? height = freezed,Object? format = freezed,}) {
  return _then(_self.copyWith(
secureUrl: null == secureUrl ? _self.secureUrl : secureUrl // ignore: cast_nullable_to_non_nullable
as String,publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudinaryUploadResult].
extension CloudinaryUploadResultPatterns on CloudinaryUploadResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudinaryUploadResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudinaryUploadResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudinaryUploadResult value)  $default,){
final _that = this;
switch (_that) {
case _CloudinaryUploadResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudinaryUploadResult value)?  $default,){
final _that = this;
switch (_that) {
case _CloudinaryUploadResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String secureUrl,  String publicId,  int? width,  int? height,  String? format)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudinaryUploadResult() when $default != null:
return $default(_that.secureUrl,_that.publicId,_that.width,_that.height,_that.format);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String secureUrl,  String publicId,  int? width,  int? height,  String? format)  $default,) {final _that = this;
switch (_that) {
case _CloudinaryUploadResult():
return $default(_that.secureUrl,_that.publicId,_that.width,_that.height,_that.format);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String secureUrl,  String publicId,  int? width,  int? height,  String? format)?  $default,) {final _that = this;
switch (_that) {
case _CloudinaryUploadResult() when $default != null:
return $default(_that.secureUrl,_that.publicId,_that.width,_that.height,_that.format);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloudinaryUploadResult extends CloudinaryUploadResult {
  const _CloudinaryUploadResult({required this.secureUrl, required this.publicId, this.width, this.height, this.format}): super._();
  factory _CloudinaryUploadResult.fromJson(Map<String, dynamic> json) => _$CloudinaryUploadResultFromJson(json);

@override final  String secureUrl;
@override final  String publicId;
@override final  int? width;
@override final  int? height;
@override final  String? format;

/// Create a copy of CloudinaryUploadResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudinaryUploadResultCopyWith<_CloudinaryUploadResult> get copyWith => __$CloudinaryUploadResultCopyWithImpl<_CloudinaryUploadResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloudinaryUploadResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudinaryUploadResult&&(identical(other.secureUrl, secureUrl) || other.secureUrl == secureUrl)&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureUrl,publicId,width,height,format);

@override
String toString() {
  return 'CloudinaryUploadResult(secureUrl: $secureUrl, publicId: $publicId, width: $width, height: $height, format: $format)';
}


}

/// @nodoc
abstract mixin class _$CloudinaryUploadResultCopyWith<$Res> implements $CloudinaryUploadResultCopyWith<$Res> {
  factory _$CloudinaryUploadResultCopyWith(_CloudinaryUploadResult value, $Res Function(_CloudinaryUploadResult) _then) = __$CloudinaryUploadResultCopyWithImpl;
@override @useResult
$Res call({
 String secureUrl, String publicId, int? width, int? height, String? format
});




}
/// @nodoc
class __$CloudinaryUploadResultCopyWithImpl<$Res>
    implements _$CloudinaryUploadResultCopyWith<$Res> {
  __$CloudinaryUploadResultCopyWithImpl(this._self, this._then);

  final _CloudinaryUploadResult _self;
  final $Res Function(_CloudinaryUploadResult) _then;

/// Create a copy of CloudinaryUploadResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secureUrl = null,Object? publicId = null,Object? width = freezed,Object? height = freezed,Object? format = freezed,}) {
  return _then(_CloudinaryUploadResult(
secureUrl: null == secureUrl ? _self.secureUrl : secureUrl // ignore: cast_nullable_to_non_nullable
as String,publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

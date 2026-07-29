// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String? ?? '',
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  role: json['role'] == null
      ? UserRole.customer
      : _roleFromJson(json['role'] as String),
  fcmToken: json['fcmToken'] as String?,
  profileImage: json['profileImage'] as String?,
  createdAt: _userDateTimeFromJson(json['createdAt'] as String),
  updatedAt: _userDateTimeFromJson(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': _roleToJson(instance.role),
      'fcmToken': instance.fcmToken,
      'profileImage': instance.profileImage,
      'createdAt': _userDateTimeToJson(instance.createdAt),
      'updatedAt': _userDateTimeToJson(instance.updatedAt),
    };

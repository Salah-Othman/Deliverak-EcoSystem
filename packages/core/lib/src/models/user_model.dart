import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/user_role.dart';
import '../exceptions/app_exception.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

DateTime _userDateTimeFromJson(String value) => DateTime.parse(value);
String _userDateTimeToJson(DateTime value) => value.toIso8601String();

UserRole _roleFromJson(String value) => UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );

String _roleToJson(UserRole role) => role.name;

@Freezed(copyWith: false)
abstract class UserModel with _$UserModel {
  const factory UserModel({
    @Default('') String uid,
    @Default('') String name,
    @Default('') String email,
    @Default('') String phone,
    @JsonKey(toJson: _roleToJson, fromJson: _roleFromJson)
    @Default(UserRole.customer) UserRole role,
    String? fcmToken,
    String? profileImage,
    @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)
    required DateTime createdAt,
    @JsonKey(toJson: _userDateTimeToJson, fromJson: _userDateTimeFromJson)
    required DateTime updatedAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now().toIso8601String();
    return UserModel.fromJson({
      'createdAt': now,
      'updatedAt': now,
      ...map,
    });
  }

  Map<String, dynamic> toMap() => toJson();

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? fcmToken,
    String? profileImage,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  void validate() {
    if (uid.trim().isEmpty) {
      throw const ValidationException(message: 'User ID is required');
    }
    if (name.trim().isEmpty || name.trim().length > 50) {
      throw const ValidationException(message: 'Name must be 1–50 characters');
    }
    if (phone.trim().isEmpty || !RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(phone.trim())) {
      throw const ValidationException(message: 'Enter a valid phone number with country code');
    }
    if (email.trim().isNotEmpty && !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      throw const ValidationException(message: 'Enter a valid email address');
    }
  }
}

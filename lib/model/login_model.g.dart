// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) {
  return LoginModel(
      access_token: json['access_token'] as String?,
      expiresIn: json['expiresIn'] as num?,
      refresh_token: json['refresh_token'] as String?,
      expiration: json['expiration'] as num?);
}

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'access_token': instance.access_token,
      'expiresIn': instance.expiresIn,
      'refresh_token': instance.refresh_token,
      'expiration': instance.expiration
    };

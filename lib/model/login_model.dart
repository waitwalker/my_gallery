import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  // ignore: non_constant_identifier_names
  String? access_token;
  num? expiresIn;
  // ignore: non_constant_identifier_names
  String? refresh_token;
  num? expiration;

  LoginModel(
      // ignore: non_constant_identifier_names
      {this.access_token, this.expiresIn, this.refresh_token, this.expiration});

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

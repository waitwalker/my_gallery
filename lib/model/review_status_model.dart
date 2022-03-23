import 'package:json_annotation/json_annotation.dart';

part 'review_status_model.g.dart';
///
/// @description 上架审核状态 model
/// @author waitwalker
/// @time 2021/5/7 15:06
///
@JsonSerializable()
class ReviewStatusModel {
  num? code;
  String? msg;
  DataEntity? data;

  ReviewStatusModel({this.code, this.msg, this.data});

  factory ReviewStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewStatusModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? ia;

  DataEntity({this.ia});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);
}

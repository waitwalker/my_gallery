import 'package:json_annotation/json_annotation.dart';

part 'video_record_model.g.dart';

@JsonSerializable()
class VideoRecordModel {
  num? code;
  String? msg;
  DataEntity? data;

  VideoRecordModel({this.code, this.msg, this.data});

  factory VideoRecordModel.fromJson(Map<String, dynamic> json) =>
      _$VideoRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoRecordModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? logId;

  DataEntity({this.logId});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);
}

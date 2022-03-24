import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

///
/// @description 知识导学文档model
/// @author waitwalker
/// @time 2021/5/7 15:19
///
@JsonSerializable()
class DocumentModel {
  num? code;
  List<DataEntity>? data;
  String? msg;

  DocumentModel({this.code, this.data, this.msg});

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? resId;
  String? resName;

  DataEntity({this.resId, this.resName});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);
}

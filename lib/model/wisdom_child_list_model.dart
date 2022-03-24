import 'package:json_annotation/json_annotation.dart';

part 'wisdom_child_list_model.g.dart';

///
/// @description 智慧学习 章节模式model
/// @author waitwalker
/// @time 2021/5/7 15:35
///
@JsonSerializable()
class WisdomChildListModel {
  num? code;
  List<DataEntity>? data;
  String? msg;

  WisdomChildListModel({this.code, this.data, this.msg});

  factory WisdomChildListModel.fromJson(Map<String, dynamic> json) =>
      _$WisdomChildListModelFromJson(json);

  Map<String, dynamic> toJson() => _$WisdomChildListModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? nodeId;
  String? nodeName;
  List<ResourceIdListEntity>? resourceIdList;

  DataEntity({this.nodeId, this.nodeName, this.resourceIdList});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);

  // added by hand
  List<DataEntity>? children;

  /// 章1 default
  /// 节2
  /// 知识点3
  int? type = 1;
}

@JsonSerializable()
class ResourceIdListEntity {
  String? cTime;
  num? clicks;
  num? diffType;
  num? downloadnum;
  num? fileSize;
  String? fileSuffixname;
  num? fileType;
  num? grade;
  String? mTime;
  num? netShareStatus;
  num? reportnum;
  num? resDegree;
  num? resId;
  String? resIntroduce;
  String? resName;
  num? resScore;
  num? resSource;
  num? resStatus;
  num? resType;
  num? shareStatus;
  num? storenum;
  num? subject;
  num? totalShareStatus;
  num? userId;

  ResourceIdListEntity(
      {this.cTime,
      this.clicks,
      this.diffType,
      this.downloadnum,
      this.fileSize,
      this.fileSuffixname,
      this.fileType,
      this.grade,
      this.mTime,
      this.netShareStatus,
      this.reportnum,
      this.resDegree,
      this.resId,
      this.resIntroduce,
      this.resName,
      this.resScore,
      this.resSource,
      this.resStatus,
      this.resType,
      this.shareStatus,
      this.storenum,
      this.subject,
      this.totalShareStatus,
      this.userId});

  factory ResourceIdListEntity.fromJson(Map<String, dynamic> json) =>
      _$ResourceIdListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceIdListEntityToJson(this);
}

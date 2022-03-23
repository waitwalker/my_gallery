import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wisdom_model.g.dart';
///
/// @description 智慧学习 诊学练测模式model
/// @author waitwalker
/// @time 2021/5/7 15:35
///
@JsonSerializable()
class WisdomModel {
  num? code;
  List<DataEntity>? data;
  String? msg;

  WisdomModel({this.code, this.data, this.msg});

  factory WisdomModel.fromJson(Map<String, dynamic> json, {bool canMinus = false}) =>
      _$WisdomModelFromJson(json, canMinus: canMinus);

  Map<String, dynamic> toJson() => _$WisdomModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? nodeId;///节点id
  String? nodeName;///节点名称
  List<ResourceIdListEntity>? resourceIdList;///资源id列表
  num? level;///层级
  List<DataEntity>? nodeList;///节点列表
  num? progress;
  num? answerNumber; ///已作答数量
  num? questionsNumber; ///题目总数量

  DataEntity({
    this.nodeId,
    this.nodeName,
    this.resourceIdList,
    this.level,
    this.nodeList,
    this.expanded,
    this.previewModeCanTap,
    this.progress,
    this.answerNumber,
    this.questionsNumber,
  });

  factory DataEntity.fromJson(Map<String, dynamic> json, {bool canMinus = false}) =>
      _$DataEntityFromJson(json, canMinus: canMinus);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);

  // add by hand
  bool? expanded = true;
  /// 预览模式是否可以点击 默认不可以点击  只有前两个可以点击
  bool? previewModeCanTap = false;
}

@JsonSerializable()
// ignore: must_be_immutable
class ResourceIdListEntity extends Equatable {
  num? resId;
  String? resName;
  num? resType;
  String? srcABPaperQuesIds;
  num? studyStatus;

  int? aiNodeId;
  String? cTime;
  int? clicks;
  int? diffType;
  int? downloadnum;
  int? fileSize;
  String? fileSuffixname;
  int? fileType;
  int? grade;
  String? levelStr;
  String? mTime;
  int? netShareStatus;
  int? reportnum;
  int? resDegree;
  String? resIntroduce;
  int? resScore;
  int? resSource;
  int? resStatus;
  int? shareStatus;
  int? storenum;
  int? subject;
  int? totalShareStatus;
  int? userId;

  ResourceIdListEntity({
    this.resId,
    this.resName,
    this.resType,
    this.srcABPaperQuesIds,
    this.studyStatus,


    this.aiNodeId,
    this.cTime,
    this.clicks,
    this.diffType,
    this.downloadnum,
    this.fileSize,
    this.fileSuffixname,
    this.fileType,
    this.grade,
    this.levelStr,
    this.mTime,
    this.netShareStatus,
    this.reportnum,
    this.resDegree,
    this.resIntroduce,
    this.resScore,
    this.resSource,
    this.resStatus,
    this.shareStatus,
    this.storenum,
    this.subject,
    this.totalShareStatus,
    this.userId,
  });

  factory ResourceIdListEntity.fromJson(Map<String, dynamic> json) =>
      _$ResourceIdListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceIdListEntityToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

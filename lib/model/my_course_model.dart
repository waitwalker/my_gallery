import 'package:json_annotation/json_annotation.dart';

part 'my_course_model.g.dart';

///
/// @description 我的课程 智领智学课程卡片model
/// @author waitwalker
/// @time 2021/5/7 15:26
///
@JsonSerializable()
class MyCourseModel {
  num? code;
  String? msg;
  List<DataEntity>? data;

  MyCourseModel({this.code, this.msg, this.data});

  factory MyCourseModel.fromJson(Map<String, dynamic> json) =>
      _$MyCourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyCourseModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  num? subjectId;
  String? subjectName;
  List<GradesEntity>? grades;

  DataEntity({this.subjectId, this.subjectName, this.grades});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);
}

@JsonSerializable()
class GradesEntity {
  num? gradeId;
  String? gradeName;
  num? showLiveStatus;

  GradesEntity({this.gradeId, this.gradeName, this.showLiveStatus = 0});

  factory GradesEntity.fromJson(Map<String, dynamic> json) =>
      _$GradesEntityFromJson(json);

  Map<String, dynamic> toJson() => _$GradesEntityToJson(this);
}

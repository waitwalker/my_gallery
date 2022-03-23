// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCourseModel _$MyCourseModelFromJson(Map<String, dynamic> json) {
  return MyCourseModel(
      code: json['code'] as num?,
      msg: json['msg'] as String?,
      data: (json['data'])
          ?.map((e) =>
              e == null ? null : DataEntity.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$MyCourseModelToJson(MyCourseModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data
    };

DataEntity _$DataEntityFromJson(Map<String, dynamic> json) {
  return DataEntity(
      subjectId: json['subjectId'] as num?,
      subjectName: json['subjectName'] as String?,
      grades: (json['grades'])
          ?.map((e) => e == null
              ? null
              : GradesEntity.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DataEntityToJson(DataEntity instance) =>
    <String, dynamic>{
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'grades': instance.grades
    };

GradesEntity _$GradesEntityFromJson(Map<String, dynamic> json) {
  return GradesEntity(
      gradeId: json['gradeId'] as num?, gradeName: json['gradeName'] as String?, showLiveStatus: json['showLiveStatus'] as num?,);
}

Map<String, dynamic> _$GradesEntityToJson(GradesEntity instance) =>
    <String, dynamic>{
      'gradeId': instance.gradeId,
      'gradeName': instance.gradeName,
      'showLiveStatus': instance.showLiveStatus
    };

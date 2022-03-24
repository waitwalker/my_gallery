// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoRecordModel _$VideoRecordModelFromJson(Map<String, dynamic> json) {
  return VideoRecordModel(
      code: json['code'] as num?,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : DataEntity.fromJson(json['data'] as Map<String, dynamic>));
}

Map<String, dynamic> _$VideoRecordModelToJson(VideoRecordModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data
    };

DataEntity _$DataEntityFromJson(Map<String, dynamic> json) {
  return DataEntity(logId: json['logId'] as num?);
}

Map<String, dynamic> _$DataEntityToJson(DataEntity instance) =>
    <String, dynamic>{'logId': instance.logId};

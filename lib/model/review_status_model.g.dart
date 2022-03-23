// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewStatusModel _$ReviewStatusModelFromJson(Map<String, dynamic> json) {
  return ReviewStatusModel(
      code: json['code'] as num?,
      msg: json['msg'] as String?,
      data: json['data'] == null
          ? null
          : DataEntity.fromJson(json['data'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ReviewStatusModelToJson(ReviewStatusModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data
    };

DataEntity _$DataEntityFromJson(Map<String, dynamic> json) {
  return DataEntity(ia: json['ia'] as num?);
}

Map<String, dynamic> _$DataEntityToJson(DataEntity instance) =>
    <String, dynamic>{'ia': instance.ia};

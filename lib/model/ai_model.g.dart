// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiModel _$AiModelFromJson(Map<String, dynamic> json) {
  return AiModel(
      code: json['code'] as num?,
      msg: json['msg'] as String?,
      data: (json['data'])
          ?.map((e) =>
              e == null ? null : Data.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$AiModelToJson(AiModel instance) => <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data
    };

Data _$DataEntityFromJson(Map<String, dynamic> json) {
  return Data(
      materialId: json['materialId'] as num?,
      newChapter: json['newChapter'] as bool?,
      chapterName: json['chapterName'] as String?,
      chapterId: json['chapterId'] as num?,
      level: json['level'] as num?,
      orderId: json['orderId'] as num?,
      publishable: json['publishable'] as bool?,
      starNum: json['starNum'] as num?,
      score: json['score'] as num?,
      parentId: json['parentId'] as num? ?? -1,
      chapterList: (json['chapterList'])
          ?.map((e) =>
              e == null ? null : Data.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$DataEntityToJson(Data instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'newChapter': instance.newChapter,
      'chapterName': instance.chapterName,
      'chapterId': instance.chapterId,
      'level': instance.level,
      'orderId': instance.orderId,
      'publishable': instance.publishable,
      'starNum': instance.starNum,
      'score': instance.score,
      'parentId': instance.parentId,
      'chapterList': instance.chapterList
    };

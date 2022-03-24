// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wisdom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WisdomModel _$WisdomModelFromJson(Map<String, dynamic> json, {bool canMinus = false}) {
  return WisdomModel(
      code: json['code'] as num?,
      data: (json['data'] )
          ?.map((e) =>
              e == null ? null : DataEntity.fromJson(e as Map<String, dynamic>, canMinus: canMinus))
          ?.toList(),
      msg: json['msg'] as String?);
}

Map<String, dynamic> _$WisdomModelToJson(WisdomModel instance) => <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg
    };

DataEntity _$DataEntityFromJson(Map<String, dynamic> json, {bool canMinus = false}) {
  return DataEntity(
      previewModeCanTap: json['canTap'] ?? false,
      nodeId: json['nodeId'] as num?,
      progress: json['progress'] as num?,
      answerNumber: json['answerNumber'] as num?,
      questionsNumber: json['questionsNumber'] as num?,
      nodeName: json['nodeName'] as String?,
      resourceIdList: (json['resourceIdList'] )
          ?.map((e) => e == null
              ? null
              : ResourceIdListEntity.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      level: canMinus ? (json['level'] as num) - 1 : (json['level'] as num?),
      nodeList: (json['nodeList'] )
          ?.map((e) =>
              e == null ? null : DataEntity.fromJson(e as Map<String, dynamic>, canMinus: canMinus))
          ?.toList())
    ..expanded = json['expanded'] as bool?;
}

Map<String, dynamic> _$DataEntityToJson(DataEntity instance) =>
    <String, dynamic>{
      'nodeId': instance.nodeId,
      'nodeName': instance.nodeName,
      'progress': instance.progress,
      'answerNumber': instance.answerNumber,
      'questionsNumber': instance.questionsNumber,
      'resourceIdList': instance.resourceIdList,
      'level': instance.level,
      'nodeList': instance.nodeList,
      'expanded': instance.expanded,
      'canTap':instance.previewModeCanTap,
    };

ResourceIdListEntity _$ResourceIdListEntityFromJson(Map<String, dynamic> json) {
  return ResourceIdListEntity(
    resId: json['resId'] as num?,
    resName: json['resName'] as String?,
    resType: json['resType'] as num?,
    srcABPaperQuesIds: json['srcABPaperQuesIds'] as String?,
    studyStatus: json['studyStatus'] as num?,

    aiNodeId: (json['aiNodeId'] as num?) as int?,
    cTime: json['cTime'] as String?,
    clicks: (json['clicks'] as num?) as int?,
    diffType: (json['diffType'] as num?) as int?,
    downloadnum: (json['downloadnum'] as num?) as int?,
    fileSize: (json['fileSize'] as num?) as int?,
    fileSuffixname: json['fileSuffixname'] as String?,
    fileType: (json['fileType'] as num?) as int?,
    grade: (json['grade'] as num?) as int?,
    levelStr: json['levelStr'] as String?,
    mTime: json['mTime'] as String?,
    netShareStatus: (json['netShareStatus'] as num?) as int?,
    reportnum: (json['reportnum'] as num?) as int?,
    resDegree: (json['resDegree'] as num?) as int?,
    resIntroduce: json['resIntroduce'] as String?,
    resScore: (json['resScore'] as num?) as int?,
    resSource: (json['resSource'] as num?) as int?,
    resStatus: (json['resStatus'] as num?) as int?,
    shareStatus: (json['shareStatus'] as num?) as int?,
    storenum: (json['storenum'] as num?) as int?,
    subject: (json['subject'] as num?) as int?,
    totalShareStatus: (json['totalShareStatus'] as num?) as int?,
    userId: (json['userId'] as num?) as int?,
  );
}

Map<String, dynamic> _$ResourceIdListEntityToJson(
        ResourceIdListEntity instance) =>
    <String, dynamic>{
      'resId': instance.resId,
      'resName': instance.resName,
      'resType': instance.resType,
      'srcABPaperQuesIds': instance.srcABPaperQuesIds,
      'studyStatus': instance.studyStatus,


      'aiNodeId': instance.aiNodeId,
      'cTime': instance.cTime,
      'clicks': instance.clicks,
      'diffType': instance.diffType,
      'downloadnum': instance.downloadnum,

      'fileSize': instance.fileSize,
      'fileSuffixname': instance.fileSuffixname,
      'fileType': instance.fileType,
      'grade': instance.grade,
      'levelStr': instance.levelStr,

      'mTime': instance.mTime,
      'netShareStatus': instance.netShareStatus,
      'reportnum': instance.reportnum,
      'resDegree': instance.resDegree,
      'resIntroduce': instance.resIntroduce,

      'resScore': instance.resScore,
      'resSource': instance.resSource,
      'resStatus': instance.resStatus,
      'shareStatus': instance.shareStatus,
      'storenum': instance.storenum,

      'subject': instance.subject,
      'totalShareStatus': instance.totalShareStatus,
      'userId': instance.userId,
    };

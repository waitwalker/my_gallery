import 'package:json_annotation/json_annotation.dart';

part 'live_schedule_model.g.dart';

@JsonSerializable()
class LiveScheduleModel {
  num? code;
  String? msg;
  DataEntity? data;

  LiveScheduleModel({this.code, this.msg, this.data});

  factory LiveScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$LiveScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$LiveScheduleModelToJson(this);
}

@JsonSerializable()
class DataEntity {
  List<ListEntity>? list;
  String? classCode;
  String? coursewareUrl;

  DataEntity({this.list, this.classCode, this.coursewareUrl});

  factory DataEntity.fromJson(Map<String, dynamic> json) =>
      _$DataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DataEntityToJson(this);
}

@JsonSerializable()
class ListEntity {
  num? courseId;
  String? courseName;
  String? courseDesc;
  num? gradeId;
  num? subjectId;
  String? startTime;
  String? endTime;
  String? partnerName;
  String? partnerRoomId;
  num? hdResourceId;
  num? liveCourseId;
  num? teacherId;
  String? teacherName;
  String? showName;
  num? teacherType;
  String? teacherIntroduce;
  String? teacherPic;
  String? weekDay;
  num? stateId;
  num? workStatus;
  int? itemIndex;
  DownloadTaskInfo? downloadTaskInfo;
  String? progress;
  // 直播类型 1=cc直播，2=保利威直播
  num? partnerRoomType;

  ListEntity(
      {this.courseId,
        this.courseName,
        this.courseDesc,
        this.gradeId,
        this.subjectId,
        this.startTime,
        this.endTime,
        this.partnerName,
        this.partnerRoomId,
        this.hdResourceId,
        this.liveCourseId,
        this.teacherId,
        this.teacherName,
        this.showName,
        this.teacherType,
        this.teacherIntroduce,
        this.teacherPic,
        this.weekDay,
        this.stateId,
        this.workStatus,
        this.itemIndex,
        this.downloadTaskInfo,
        this.progress,
        this.partnerRoomType
      });

  factory ListEntity.fromJson(Map<String, dynamic> json) =>
      _$ListEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ListEntityToJson(this);
}

class DownloadTaskInfo {
  String? name = "";
  String? link = "";

  String taskId = "";
  int progress = 0;
  int? currentIndex = 0;

  DownloadTaskInfo({this.name, this.link, this.currentIndex, this.progress = 0, this.taskId = ""});
}

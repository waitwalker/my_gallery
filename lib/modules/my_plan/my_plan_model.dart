class MyPlanModel {
  int? code;
  String? msg;
  List<Data>? data;

  MyPlanModel({this.code, this.msg, this.data});

  MyPlanModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? subjectId;
  String? subjectName;
  List<Plans>? plans;
  bool isSelected = false;

  Data({this.subjectId, this.subjectName, this.plans});

  Data.fromJson(Map<String, dynamic> json) {
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    if (json['plans'] != null) {
      plans = [];
      json['plans'].forEach((v) {
        plans!.add(new Plans.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subjectId'] = this.subjectId;
    data['subjectName'] = this.subjectName;
    if (this.plans != null) {
      data['plans'] = this.plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plans {
  int? planId;
  String? planName;
  String? planDesc;
  List<Tasks>? tasks;
  bool isSelected = false;
  Plans({this.planId, this.planName, this.planDesc, this.tasks});

  Plans.fromJson(Map<String, dynamic> json) {
    planId = json['planId'];
    planName = json['planName'];
    planDesc = json['planDesc'];
    if (json['tasks'] != null) {
      tasks = [];
      json['tasks'].forEach((v) {
        tasks!.add(new Tasks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['planId'] = this.planId;
    data['planName'] = this.planName;
    data['planDesc'] = this.planDesc;
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tasks {
  int? resourceId;
  int? resourceType;
  String? resourceName;
  int? sortId;
  String? planTime;
  int? taskId;
  int? isFinish;
  int? finishId;
  String? finishTime;
  String? questionIds;
  String? paperType;
  int? liveCourseId;
  int? courseId;
  String? roomId;
  int? cardCourseId = 0;

  Tasks(
      {this.resourceId,
        this.resourceType,
        this.resourceName,
        this.sortId,
        this.planTime,
        this.taskId,
        this.isFinish,
        this.finishId,
        this.finishTime,
        this.questionIds,
        this.paperType,
        this.liveCourseId,
        this.courseId,
        this.roomId,
        this.cardCourseId
      });

  Tasks.fromJson(Map<String, dynamic> json) {
    resourceId = json['resourceId'];
    resourceType = json['resourceType'];
    resourceName = json['resourceName'];
    sortId = json['sortId'];
    planTime = json['planTime'];
    taskId = json['taskId'];
    isFinish = json['isFinish'];
    finishId = json['finishId'];
    finishTime = json['finishTime'];
    questionIds = json['questionIds'];
    paperType = json['paperType'];
    liveCourseId = json['liveCourseId'];
    courseId = json['courseId'];
    roomId = json['roomId'];
    cardCourseId = json['cardCourseId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resourceId'] = this.resourceId;
    data['resourceType'] = this.resourceType;
    data['resourceName'] = this.resourceName;
    data['sortId'] = this.sortId;
    data['planTime'] = this.planTime;
    data['taskId'] = this.taskId;
    data['isFinish'] = this.isFinish;
    data['finishId'] = this.finishId;
    data['finishTime'] = this.finishTime;
    data['questionIds'] = this.questionIds;
    data['paperType'] = this.paperType;
    data['liveCourseId'] = this.liveCourseId;
    data['courseId'] = this.courseId;
    data['roomId'] = this.roomId;
    data['cardCourseId'] = this.cardCourseId;
    return data;
  }
}
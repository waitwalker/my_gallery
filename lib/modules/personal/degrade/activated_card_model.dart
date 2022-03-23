class ActivatedCardModel {
  int? code;
  String? msg;
  List<Data>? data;

  ActivatedCardModel({this.code, this.msg, this.data});

  ActivatedCardModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? ref;
  int? cardId;
  int? courseId;
  String? realCardId;
  String? beginTime;
  String? endTime;
  String? userName;
  int? gradeId;
  int? subjectId;
  String? courseName;
  String? createTime;
  int? userId;
  int? isModify;
  String? courseCardName;
  String? gradeName;
  String? subjectName;

  Data(
      {this.ref,
        this.cardId,
        this.courseId,
        this.realCardId,
        this.beginTime,
        this.endTime,
        this.userName,
        this.gradeId,
        this.subjectId,
        this.courseName,
        this.createTime,
        this.userId,
        this.isModify,
        this.courseCardName,
        this.gradeName,
        this.subjectName});

  Data.fromJson(Map<String, dynamic> json) {
    ref = json['ref'];
    cardId = json['cardId'];
    courseId = json['courseId'];
    realCardId = json['realCardId'];
    beginTime = json['beginTime'];
    endTime = json['endTime'];
    userName = json['userName'];
    gradeId = json['gradeId'];
    subjectId = json['subjectId'];
    courseName = json['courseName'];
    createTime = json['createTime'];
    userId = json['userId'];
    isModify = json['isModify'];
    courseCardName = json['courseCardName'];
    gradeName = json['gradeName'];
    subjectName = json['subjectName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ref'] = this.ref;
    data['cardId'] = this.cardId;
    data['courseId'] = this.courseId;
    data['realCardId'] = this.realCardId;
    data['beginTime'] = this.beginTime;
    data['endTime'] = this.endTime;
    data['userName'] = this.userName;
    data['gradeId'] = this.gradeId;
    data['subjectId'] = this.subjectId;
    data['courseName'] = this.courseName;
    data['createTime'] = this.createTime;
    data['userId'] = this.userId;
    data['isModify'] = this.isModify;
    data['courseCardName'] = this.courseCardName;
    data['gradeName'] = this.gradeName;
    data['subjectName'] = this.subjectName;
    return data;
  }
}
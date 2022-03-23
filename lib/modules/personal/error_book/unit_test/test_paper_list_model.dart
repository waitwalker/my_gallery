
class TestPaperListModel {
  int? code;
  String? msg;
  List<DataSource>? data;

  TestPaperListModel({this.code, this.msg, this.data});

  TestPaperListModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(DataSource.fromJson(v));
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

class DataSource {
  int? taskId;
  int? paperId;
  int? gradeId;
  int? subjectId;
  String? subjectName;
  String? paperName;
  int? surplusCnt;
  int? totalCnt;
  int? startStatus;

  DataSource(
      {this.taskId,
        this.paperId,
        this.gradeId,
        this.subjectId,
        this.subjectName,
        this.paperName,
        this.surplusCnt,
        this.totalCnt,
        this.startStatus});

  DataSource.fromJson(Map<String, dynamic> json) {
    taskId = json['taskId'];
    paperId = json['paperId'];
    gradeId = json['gradeId'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    paperName = json['paperName'];
    surplusCnt = json['surplusCnt'];
    totalCnt = json['totalCnt'];
    startStatus = json['startStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['taskId'] = this.taskId;
    data['paperId'] = this.paperId;
    data['gradeId'] = this.gradeId;
    data['subjectId'] = this.subjectId;
    data['subjectName'] = this.subjectName;
    data['paperName'] = this.paperName;
    data['surplusCnt'] = this.surplusCnt;
    data['totalCnt'] = this.totalCnt;
    data['startStatus'] = this.startStatus;
    return data;
  }
}
class UnitTestModel {
  int? code;
  String? msg;
  DataSource? dataSource;

  UnitTestModel({this.code, this.msg, this.dataSource});

  UnitTestModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    dataSource = json['data'] != null
        ? DataSource.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    if (this.dataSource != null) {
      data['data'] = this.dataSource!.toJson();
    }
    return data;
  }
}

class DataSource {
  int? currentPage;
  int? pageSize;
  int? totalCount;
  int? totalPage;
  List<PaperList>? paperList;
  bool? firstPage;
  bool? lastPage;

  DataSource(
      {this.currentPage,
        this.pageSize,
        this.totalCount,
        this.totalPage,
        this.paperList,
        this.firstPage,
        this.lastPage});

  DataSource.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    pageSize = json['pageSize'];
    totalCount = json['totalCount'];
    totalPage = json['totalPage'];
    if (json['list'] != null) {
      paperList = [];
      json['list'].forEach((v) {
        paperList!.add(PaperList.fromJson(v));
      });
    }
    firstPage = json['firstPage'];
    lastPage = json['lastPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['pageSize'] = this.pageSize;
    data['totalCount'] = this.totalCount;
    data['totalPage'] = this.totalPage;
    if (this.paperList != null) {
      data['list'] = this.paperList!.map((v) => v.toJson()).toList();
    }
    data['firstPage'] = this.firstPage;
    data['lastPage'] = this.lastPage;
    return data;
  }
}

class PaperList {
  int? taskId;
  String? taskName;
  int? taskStatus;
  String? startTime;
  String? endTime;
  int? paperId;
  int? gradeId;
  String? gradeName;
  int? subjectId;
  String? subjectName;
  int? surplusCnt;
  int? totalCnt;
  int? isPaid;
  int? reportState;

  PaperList(
      {this.taskId,
        this.taskName,
        this.taskStatus,
        this.startTime,
        this.endTime,
        this.paperId,
        this.gradeId,
        this.gradeName,
        this.subjectId,
        this.subjectName,
        this.surplusCnt,
        this.totalCnt,
        this.isPaid,
        this.reportState});

  PaperList.fromJson(Map<String, dynamic> json) {
    taskId = json['taskId'];
    taskName = json['taskName'];
    taskStatus = json['taskStatus'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    paperId = json['paperId'];
    gradeId = json['gradeId'];
    gradeName = json['gradeName'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    surplusCnt = json['surplusCnt'];
    totalCnt = json['totalCnt'];
    isPaid = json['isPaid'];
    reportState = json['reportState'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['taskId'] = this.taskId;
    data['taskName'] = this.taskName;
    data['taskStatus'] = this.taskStatus;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['paperId'] = this.paperId;
    data['gradeId'] = this.gradeId;
    data['gradeName'] = this.gradeName;
    data['subjectId'] = this.subjectId;
    data['subjectName'] = this.subjectName;
    data['surplusCnt'] = this.surplusCnt;
    data['totalCnt'] = this.totalCnt;
    data['isPaid'] = this.isPaid;
    data['reportState'] = this.reportState;
    return data;
  }
}
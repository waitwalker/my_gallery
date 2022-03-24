class WisdomResourceModel {
  num? code;
  Data? data;
  String? msg;

  WisdomResourceModel({this.code, this.data, this.msg});

  WisdomResourceModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  num? progress;
  Diagnosis? diagnosis;
  Diagnosis? study;
  Diagnosis? practice;
  Diagnosis? test;
  Diagnosis? ordinary;
  num? intoStatus;

  Data(
      {this.progress,
        this.diagnosis,
        this.study,
        this.practice,
        this.test,
        this.intoStatus,
        this.ordinary});

  Data.fromJson(Map<String, dynamic> json) {
    progress = json['progress'];
    intoStatus = json['intoStatus'];
    diagnosis = json['diagnosis'] != null
        ? Diagnosis.fromJson(json['diagnosis'])
        : null;
    study =
    json['study'] != null ? Diagnosis.fromJson(json['study']) : null;
    practice = json['practice'] != null
        ? Diagnosis.fromJson(json['practice'])
        : null;
    test = json['test'] != null ? Diagnosis.fromJson(json['test']) : null;
    ordinary = json['ordinary'] != null
        ? Diagnosis.fromJson(json['ordinary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['progress'] = this.progress;
    data['intoStatus'] = this.intoStatus;
    if (this.diagnosis != null) {
      data['diagnosis'] = this.diagnosis!.toJson();
    }
    if (this.study != null) {
      data['study'] = this.study!.toJson();
    }
    if (this.practice != null) {
      data['practice'] = this.practice!.toJson();
    }
    if (this.test != null) {
      data['test'] = this.test!.toJson();
    }
    if (this.ordinary != null) {
      data['ordinary'] = this.ordinary!.toJson();
    }
    return data;
  }
}

class Diagnosis {
  num? labelStatus;
  num? labelOpen;
  List<ResourceList>? resourceList;

  Diagnosis({this.labelStatus, this.resourceList, this.labelOpen});

  Diagnosis.fromJson(Map<String, dynamic> json) {
    labelStatus = json['labelStatus'];
    labelOpen = json['labelOpen'];
    if (json['resourceList'] != null) {
      resourceList = [];
      json['resourceList'].forEach((v) {
        resourceList!.add(ResourceList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['labelStatus'] = this.labelStatus;
    data['labelOpen'] = this.labelOpen;
    if (this.resourceList != null) {
      data['resourceList'] = this.resourceList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResourceList {
  num? resId;
  num? aiNodeId;
  String? resName;
  num? resType;
  String? srcABPaperQuesIds;
  num? studyStatus;

  ResourceList(
      {
        this.aiNodeId,
        this.resId,
        this.resName,
        this.resType,
        this.srcABPaperQuesIds,
        this.studyStatus});

  ResourceList.fromJson(Map<String, dynamic> json) {
    aiNodeId = json['aiNodeId'];
    resId = json['resId'];
    resName = json['resName'];
    resType = json['resType'];
    srcABPaperQuesIds = json['srcABPaperQuesIds'];
    studyStatus = json['studyStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['aiNodeId'] = this.aiNodeId;
    data['resId'] = this.resId;
    data['resName'] = this.resName;
    data['resType'] = this.resType;
    data['srcABPaperQuesIds'] = this.srcABPaperQuesIds;
    data['studyStatus'] = this.studyStatus;
    return data;
  }
}
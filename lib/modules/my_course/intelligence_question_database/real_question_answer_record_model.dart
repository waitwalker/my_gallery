
///
/// @description 历年真题作答记录model
/// @param 
/// @return 
/// @author waitwalker
/// @time 4/22/21 11:33 AM
///
class RealQuestionAnswerRecordModel {
  int? code;
  String? msg;
  List<Data>? data;

  RealQuestionAnswerRecordModel({this.code, this.msg, this.data});

  RealQuestionAnswerRecordModel.fromJson(Map<String, dynamic> json) {
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
  num? paperId;
  String? paperName;
  String? submitTime;

  Data({this.paperId, this.paperName, this.submitTime});

  Data.fromJson(Map<String, dynamic> json) {
    paperId = json['paperId'];
    paperName = json['paperName'];
    submitTime = json['submitTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['paperId'] = this.paperId;
    data['paperName'] = this.paperName;
    data['submitTime'] = this.submitTime;
    return data;
  }
}
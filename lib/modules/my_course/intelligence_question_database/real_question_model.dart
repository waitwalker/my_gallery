
///
/// @description 历年真题model
/// @author waitwalker
/// @time 4/22/21 11:05 AM
///
class RealQuestionModel {
  String? msg;
  num? code;
  List<Data>? data;

  RealQuestionModel({this.msg, this.code, this.data});

  RealQuestionModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    code = json['code'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['msg'] = this.msg;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  num? realPaperId;
  String? paperName;
  int? isSubmit;

  Data({this.realPaperId, this.paperName, this.isSubmit});

  Data.fromJson(Map<String, dynamic> json) {
    realPaperId = json['realPaperId'];
    paperName = json['paperName'];
    isSubmit = json['isSubmit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['realPaperId'] = this.realPaperId;
    data['paperName'] = this.paperName;
    data['isSubmit'] = this.isSubmit;
    return data;
  }
}
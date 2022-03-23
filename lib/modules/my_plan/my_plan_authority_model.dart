class MyPlanAuthorityModel {
  int? code;
  String? msg;
  int? data;

  MyPlanAuthorityModel({this.code, this.msg, this.data});

  MyPlanAuthorityModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['data'] = this.data;
    return data;
  }
}
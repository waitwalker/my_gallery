
///
/// @description 质检消错权限接口
/// @author waitwalker
/// @time 2020/10/9 10:56 AM
///
class UnitTestAuthorityModel {
  int? code;
  String? msg;
  Data? data;

  UnitTestAuthorityModel({this.code, this.msg, this.data});

  UnitTestAuthorityModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  String? userName;
  int? gradeId;
  String? className;
  String? schoolName;
  Null bearerToken;
  Null bindingMobile;
  Null defultStatus;

  Data(
      {this.userId,
        this.userName,
        this.gradeId,
        this.className,
        this.schoolName,
        this.bearerToken,
        this.bindingMobile,
        this.defultStatus});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    gradeId = json['gradeId'];
    className = json['className'];
    schoolName = json['schoolName'];
    bearerToken = json['bearerToken'];
    bindingMobile = json['bindingMobile'];
    defultStatus = json['defultStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['gradeId'] = this.gradeId;
    data['className'] = this.className;
    data['schoolName'] = this.schoolName;
    data['bearerToken'] = this.bearerToken;
    data['bindingMobile'] = this.bindingMobile;
    data['defultStatus'] = this.defultStatus;
    return data;
  }
}
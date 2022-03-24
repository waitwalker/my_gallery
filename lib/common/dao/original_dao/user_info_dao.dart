import 'dart:async';
import 'dart:convert';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:dio/dio.dart';

class UserInfoDao {
  /// 获取用户信息
  /// http://192.168.10.8:8090/display/zz/NEW-ETT-API-11-V1.0
  static getUserInfo({String? token}) async {
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/info';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var userInfo = UserInfoModel.fromJson(response.data);
      SingletonManager.sharedInstance!.mobile = userInfo.data!.mobile;

      saveCCUserInfo(jsonEncode(response.data));
      response.model = userInfo;
    }
    return response;
  }

  static setUserInfo(String userId,
      {realName, sex, birthday, address, email}) async {
    var url =
        APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/info';

    var param = {
      'userId': userId,
    };
    param['realName'] = realName;
    param['sex'] = sex.toString();
    param['birthday'] = birthday;
    param['address'] = address;
    param['email'] = email;
    var body = jsonEncode(param);

    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'PUT'));
    if (response.result) {
      var userInfo = BaseModel.fromJson(response.data);

      response.model = userInfo;
    }

    return response;
  }

  static Future saveCCUserInfo(var json) async {
    SharedPrefsUtils.putString(APIConst.USER_INFO_JSON, json);
  }

  static UserInfoModel loadUserInfo() {
    var json = SharedPrefsUtils.getString(APIConst.USER_INFO_JSON, '{}')!;
    var info = UserInfoModel.fromJson(jsonDecode(json));
    return info;
  }

  /// 激活卡之前，完善个人信息
  static completeUserInfo(
      {schoolId,
      realName,
      address,
      gradeId,
      schoolName,
      cardId,
      onlineCourseId}) async {
    var url = APIConst.kBaseServerURL +
        'api-cloudaccount-service/api/user/authentication';

    var param = {
      'schoolId': schoolId,
      'realName': realName,
      'address': address,
      'gradeId': gradeId,
      'schoolName': schoolName,
      'cardId': cardId,
      'onlineCourseId': onlineCourseId
    };
    var body = jsonEncode(param);

    var headers = {'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var userInfo = BaseModel.fromJson(response.data);

      response.model = userInfo;
    }

    return response;
  }
}

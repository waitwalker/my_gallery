import 'dart:async';
import 'dart:convert';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:dio/dio.dart';

class LoginDao {
  static Future<ResponseData> login(var username, var password) async {
    NetworkManager.clearAuthorization();
    var params = <String, String>{'username': username, 'password': password};
    var url = APIConst.kBaseServerURL + 'authentication-center/authentication/login' + '?' + mapToQuery(params);
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'POST'));
    if (response.result) {
      if (response.code == 401) {
        if (response.data is Map) {
          response.data = response.data['msg'];
        } else {
          response.data = null;
        }
        response.result = false;
        return response;
      }

      var ccLoginModel = LoginModel.fromJson(response.data);
      saveCCLogin(jsonEncode(response.data));
      response.model = ccLoginModel;
    }
    return response;
  }

  static Future<ResponseData> checkCodeFetch() async {
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/check/code';
    var response = await NetworkManager.netFetch(url, null, null, null, forceBasicToken: true);
    return response;
  }

  static Future<ResponseData> checkCode(var username, var password, var checkCode) async {
    NetworkManager.clearAuthorization();
    var params = <String, String>{'userName': username, 'password': password, 'checkCode':checkCode};
    var body = jsonEncode({
      "userName": username,
      "password": password,
      "checkCode":checkCode
    });
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/check/password/username';
    var response = await NetworkManager.netFetch(url, body, null, Options(method: 'POST'), forceBasicToken: true);
    return response;
  }

  static Future saveCCLogin(var json) async {
    SharedPrefsUtils.putString(APIConst.LOGIN_JSON, json);
  }

  /// 退出登录
  /// http://int.etiantian.com:39804/pages/viewpage.action?pageId=183926799
  static Future<ResponseData> logout() async {
    var url = APIConst.kBaseServerURL + 'authentication-center/authentication/logout';
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'POST'));
    if (response.result) {
      NetworkManager.clearAuthorization();
    }
    return response;
  }

  static Future<ResponseData> changePassword(
      var oldPassword, var newPassword) async {
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/info/password';

    var headers = <String, String>{'content-type': 'application/json'};
    String jsonParam =
        jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword});
    var response =
        await NetworkManager.netFetch(url, jsonParam, headers, Options(method: 'PUT'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// 自动报名
  static Future<ResponseData> autoJoin() async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/register/auto/v3';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  static Future<ResponseData> findPassword(
      var mobile, var phoneCode, var newPassword) async {
    var url = APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/password';
    var headers = {'content-type': 'application/json'};
    var body = jsonEncode(
        {"mobile": mobile, "phoneCode": phoneCode, "newPassword": newPassword});
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'PUT'));
    if (response.result) {
      var model = BaseModel.fromJson(response.data);
      response.model = model;
      if (model.code != 1) {
        response.result = false;
      }
    }
    return response;
  }

  static loginByCode(String mobile, String mobileCode) async {
    var url = APIConst.kBaseServerURL +
        'authentication-center/authentication/mobileCode';
    var query = mapToQuery({'mobile': mobile, 'mobileCode': mobileCode});
    url += '?$query';
    var response = await NetworkManager.netFetch(url, null, null, Options(method: 'POST'),
        forceBasicToken: true);
    if (response.result && response.code != 401) {
      var ccLoginModel = LoginModel.fromJson(response.data);
      saveCCLogin(jsonEncode(response.data));

      response.model = ccLoginModel;
    }
    return response;
  }
}

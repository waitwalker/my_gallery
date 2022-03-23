import 'dart:convert';
import 'package:my_gallery/model/base_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:dio/dio.dart';

class RegisterDao {
  static register(String mobile, String code, String pwd, String? province, String? city, String? regionId) async {
    var url =
        APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/register';
    var body =
    jsonEncode({"mobile": mobile, "phoneCode": code, "password": pwd, "province": province, "city": city, "regionId": regionId});
    var headers = {'content-type': 'application/json'};
    var response = await NetworkManager.netFetch(
        url, body, headers, Options(method: 'POST'),
        forceBasicToken: true);

    if (response.result) {
      var model = BaseModel.fromJson(response.data);

      if (model.code != 1) {
        response.result = false;
      }
      response.model = model;
    }

    return response;
  }

  static bindPhone(String mobile, String code) async {
    var url =
        APIConst.kBaseServerURL + 'api-cloudaccount-service/api/user/bind';
    var body = jsonEncode({"mobile": mobile, "phoneCode": code});
    var headers = {'content-type': 'application/json'};
    var response =
    await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));

    if (response.result) {
      var model = BaseModel.fromJson(response.data);

      if (model.code != 1) {
        response.result = false;
      }
      response.model = model;
    }

    return response;
  }
}

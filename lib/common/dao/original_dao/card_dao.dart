import 'dart:convert';
import 'package:my_gallery/model/activate_model.dart';
import 'package:my_gallery/model/card_list_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:dio/dio.dart';

class CardDao {
  static Future<ResponseData> getCards(var cardNumber, var cardPassword) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/card/verification/v2';
    url = url + '?' + 'cardNumber=$cardNumber&cardPassword=$cardPassword';
    var response = await NetworkManager.netFetch(url, null, null, null);
    if (response.result) {
      var model = CardListModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }

  /// http://int.etiantian.com:39804/display/zz/NEW-ETT-API-27-V2.0
  static Future<ResponseData> activate(
      var cardNumber, var cardPassword, List<num?> onlineCourseId) async {
    var url =
        APIConst.kBaseServerURL + 'api-study-service/api/card/activation/v2';

    var body = jsonEncode({
      "cardNumber": cardNumber,
      "cardPassword": cardPassword,
      "onlineCourseId": onlineCourseId
    });
    var headers = <String, String>{'content-type': 'application/json'};
    var response =
        await NetworkManager.netFetch(url, body, headers, Options(method: 'POST'));
    if (response.result) {
      var model = ActivateModel.fromJson(response.data);
      response.model = model;
    }
    return response;
  }
}

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/logger/logger_manager.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

///http请求
class NetworkManager {
  static const CONTENT_TYPE_JSON = "application/json";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";
  static Map optionParams = {
    "timeoutMs": 165000,
    "token": null,
    "authorizationCode": null,
  };

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  static netFetch(url, params, Map<String, String>? header, Options? option,
      {noTip = false, bool forceBasicToken = false, Map<String, dynamic>? queryParameters}) async {

    print("请求参数:$queryParameters");
    /// 没有网络
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return ResponseData(
          ErrorCode.errorHandleFunction(ErrorCode.NETWORK_ERROR, "", noTip),
          false,
          ErrorCode.NETWORK_ERROR);
    }

    Map<String, String?> headers = HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (forceBasicToken) {
      headers.putIfAbsent(
          'Authorization', () => 'Basic ${APIConst.basicToken}');
    } else {
      //授权码
      var currToken = optionParams["authorizationCode"];
      // 如果不是Bearer token
      if (currToken == null || currToken.startsWith('Basic ')) {
        // 查询token
        String authorizationCode = await getAuthorization();
        // 如果还是basic，设置给header
        if (authorizationCode.startsWith('Basic ')) {
          headers["Authorization"] = authorizationCode;
        } else {
          // 如果是Bearer，保存到option
          optionParams["authorizationCode"] = 'Bearer $authorizationCode';
        }
      }
      // 如果没有token，从option里读取并设置
      headers.putIfAbsent(
          'Authorization', () => optionParams["authorizationCode"]);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = Options(method: "get");
      option.headers = headers;
    }

    print("请求方法:${option.method}");
    print("请求链接:$url");
    print("请求头参数:${option.headers}");

    Dio dio = Dio();

    ///超时
    dio.options.connectTimeout = optionParams['timeoutMs'];
    // if (Config.DEBUG) {
    var ip = SharedPrefsUtils.get('proxy_ip', '');
    var port = SharedPrefsUtils.get('proxy_port', '');
    // logD(ip);
    // logD(port);
    if (ip.isNotEmpty && port.isNotEmpty) {
      // 通用升级接口使用了错误的证书
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          debugLog('WARNING: USING PROXY $ip:$port');
          return "PROXY $ip:$port";
        };
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // if (cert.pem == PEM) {
          //   // Verify the certificate
          //   return true;
          // }
          return true;
        };
        return null;
      };
    }
    // }
    Response? response;
    try {
      // FToast toast = FToast();
      // toast.init(getIt<NavigatorService>().navigatorKey.currentContext);
      // toast.showToast(child: Text("全局context 网络组件调试 data"));
      if (url.toString().contains("api-service-course-wx/wx-chapter/node/points")){
        option.responseType = ResponseType.plain;
        response = await dio.request(url, data: params, options: option, queryParameters: queryParameters);
        print("response:${response.data}");
        final map = await parseJson(response.data);
        print("map:$map");
        response.data = map;
      } else {
        response = await dio.request(url, data: params, options: option,queryParameters: queryParameters);
        print(response);
      }

    } on DioError catch (e) {
      Response? errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = Response(statusCode: 666, requestOptions: RequestOptions(path: url));
      }
      if (e.type == DioErrorType.connectTimeout) {
        errorResponse!.statusCode = ErrorCode.NETWORK_TIMEOUT;
      }

      String resStr = json.encode(response);
      print("最终响应的数据:$resStr");

      if (Config.DEBUG) {
        print('请求异常: ' + e.toString());
        print('请求异常url: ' + url);
        print('请求异常code: ' + errorResponse.toString());
      }
      /// 密码错误这样的业务层，竟然也返回401，只好拦截了，单独处理
      if (errorResponse!.statusCode == 401) {
        /// 虽然http code 是401， 但是body是Map，也就是说http response body 是json，
        /// 需要单独处理，因为后台部分业务层操作，返回了401
        if (SingletonManager.sharedInstance!.hasOccur == false) {
          SingletonManager.sharedInstance!.hasOccur = true;
          if (errorResponse.data is Map) {
            return ResponseData(errorResponse.data, true, errorResponse.statusCode);
          } else {
            // 互踢，只能从下面字符串判断
            var onAnotherLoginWords = 'Unauthorized:The user has already logged in';
            var isAnotherLogin = onAnotherLoginWords == errorResponse.data;
            var anotherHint = '您的账号已在别处登录';

            /// 通过Event bus 发出通知
            return ResponseData(ErrorCode.errorHandleFunction(ErrorCode.EXPIRED, isAnotherLogin ? anotherHint : '未授权', noTip), false, errorResponse.statusCode);
          }
        }

      }

      return ResponseData(ErrorCode.errorHandleFunction(errorResponse.statusCode, e.message, noTip), false, errorResponse.statusCode);
    }


    ///
    /// @name debugLog
    /// @description 日志输出消息
    /// @parameters [url, params, header, option, noTip, forceBasicToken, queryParameters]
    /// @return
    /// @author waitwalker
    /// @date 2020-01-14
    ///
    debugLog({
      'method': option.method,
      'url': url,
      'body': params,
      'header': headers,
    }, tag: 'http request');

    debugLog({'statusCode': response.statusCode, 'body': json.encode(response.data)},
        tag: 'http response');

    //print("响应的数据:${json.encode(response.data)}");
    LoggerManager.info("响应的数据:${json.encode(response.data)}" + "响应的数据结束");

    try {
      if (option.contentType != null && option.contentType == "text") {
        return ResponseData(response.data, true, ErrorCode.SUCCESS);
      } else {
        var responseJson = response.data;
        if (response.statusCode == 201 && responseJson["token"] != null) {
          optionParams["authorizationCode"] = 'token ' + responseJson["token"];
          await SharedPrefsUtils.putString(
              APIConst.TOKEN_KEY, optionParams["authorizationCode"]);
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResponseData(response.data, true, ErrorCode.SUCCESS,
            headers: response.headers);
      }
    } catch (e) {
      debugLog(e.toString() + url);
      return ResponseData(response.data, false, response.statusCode,
          headers: response.headers);
    }
    return ResponseData(
        ErrorCode.errorHandleFunction(response.statusCode, "", noTip),
        false,
        response.statusCode);
  }


  // Must be top-level function
  static _parseAndDecode(String? response) {
//  return jsonDecode(response);
    // 只是在这个位子替换掉 dart 默认的解析方式，换成 json_serializable
    final map = json.decode(response!);
    print("$map");
    return map;
  }

  static parseJson(String? json) async{
    return await compute(_parseAndDecode, json);
  }

  ///清除授权
  static clearAuthorization() {
    optionParams["authorizationCode"] = null;
    SharedPrefsUtils.remove(APIConst.TOKEN_KEY);
    SharedPrefsUtils.remove(APIConst.LOGIN_JSON);
  }

  ///获取授权token
  static getAuthorization() {
    var json = SharedPrefsUtils.getString(APIConst.LOGIN_JSON, '{}')!;
    var ccLoginModel = LoginModel.fromJson(jsonDecode(json));
    String? token = ccLoginModel.access_token;
    if (token == null) {
      String basic = APIConst.basicToken;
      //通过 basic 去获取token，获取到设置，返回token
      return "Basic $basic";
    } else {
      return token;
    }
  }
}

String mapToQuery(Map<String, String?> map, {Encoding? encoding}) {
  var pairs = <List<String>>[];
  map.forEach((key, value) => pairs.add([
    Uri.encodeQueryComponent(key, encoding: encoding ?? Utf8Codec()),
    Uri.encodeQueryComponent(value!, encoding: encoding ?? Utf8Codec())
  ]));
  print("请求pairs:$pairs");
  String v = pairs.map((pair) => "${pair[0]}=${pair[1]}").join("&");
  print("拼接完的:$v");
  return pairs.map((pair) => "${pair[0]}=${pair[1]}").join("&");
}

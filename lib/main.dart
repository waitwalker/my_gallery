import 'dart:async';
import 'dart:io';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/entrance/app.dart';
import 'package:my_gallery/common/tools/umeng/umeng_tool.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umeng_plugin/umeng_plugin.dart';
import 'common/config/config.dart';
import 'common/network/error_code.dart';
import 'modules/entrance/user_privacy_app.dart';


void reportErrorAndLog(FlutterErrorDetails details) {
  ///上报错误和日志逻辑
  /// FlutterError.dumpErrorToConsole(details);
  UmengPlugin.reportError(details.toString());
  if (!Config.DEBUG) {

  }
}

FlutterErrorDetails makeDetails(Object obj, StackTrace stack) {
  // 构建错误信息
  return FlutterErrorDetails(stack: stack, exception: obj);
}



///
/// @description 入口函数
/// @param 
/// @return 
/// @author waitwalker
/// @time 4/22/21 10:31 AM
///
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // 先判断用户有没有同意用户隐私协议
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool? isAgreed = sharedPreferences.getBool("userPrivacy");
  print("isAgreed:$isAgreed");

  if (isAgreed == null) {
    runApp(UserPrivacyApp());
  } else {

    FlutterError.onError = (FlutterErrorDetails details) {
      reportErrorAndLog(details);
    };

    /// 初始化友盟统计
    await UmengTool.init();

    /// event 监听事件
    ErrorCode.eventBus.on<dynamic>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await plugin.iosInfo;
      SingletonManager.sharedInstance!.deviceName = iosDeviceInfo.name;
      SingletonManager.sharedInstance!.deviceType = iosDeviceInfo.model;
      SingletonManager.sharedInstance!.systemName = iosDeviceInfo.systemName;
      SingletonManager.sharedInstance!.systemVersion = iosDeviceInfo.systemVersion;
      if (iosDeviceInfo.model == "iPad") {
        SingletonManager.sharedInstance!.isPadDevice = true;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      } else {
        // debugPaintSizeEnabled = true;
        SingletonManager.sharedInstance!.isPadDevice = false;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      }

    } else if (Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo = await plugin.androidInfo;
      SingletonManager.sharedInstance!.deviceName = androidDeviceInfo.brand;
      SingletonManager.sharedInstance!.deviceType = androidDeviceInfo.model;
      SingletonManager.sharedInstance!.systemName = "Android";
      SingletonManager.sharedInstance!.systemVersion = androidDeviceInfo.version.release;
      MethodChannel channel = MethodChannel("com.etiantian/device_type");
      var result = await channel.invokeMethod("deviceType") ?? false;
      print("device is pad:$result");
      bool isTab = result["isTab"];
      bool? isGuanKong = result["isGuanKong"];
      SingletonManager.sharedInstance!.isGuanKong = isGuanKong;
      if (isTab) {
        SingletonManager.sharedInstance!.isPadDevice = true;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      } else {
        SingletonManager.sharedInstance!.isPadDevice = false;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      }
    }
  }
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initUserAgentState() async {
  String? userAgent, webViewUserAgent;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    userAgent = await FkUserAgent.getPropertyAsync('userAgent');
    await FkUserAgent.init();
    webViewUserAgent = FkUserAgent.webViewUserAgent;
    print('''
      applicationVersion => ${FkUserAgent.getProperty('applicationVersion')}
      systemName         => ${FkUserAgent.getProperty('systemName')}
      userAgent          => $userAgent
      webViewUserAgent   => $webViewUserAgent
      packageUserAgent   => ${FkUserAgent.getProperty('packageUserAgent')}
      ''');
  } on PlatformException {
    userAgent = webViewUserAgent = '<error>';
  }
}

///
/// @name errorHandleFunction
/// @description event 监听消息
/// @parameters
/// @return
/// @author waitwalker
/// @date 2020-01-14
///
errorHandleFunction(int? code, message) {
  switch (code) {
    case ErrorCode.NETWORK_ERROR:
      Fluttertoast.showToast(msg: '网络错误');
      break;
    case 401:
      Fluttertoast.showToast(msg: '账号在别处登录或者登录已过期,请重新登录(401)');
      break;
    case 403:
      Fluttertoast.showToast(msg: '禁止访问');
      break;
    case 404:
      Fluttertoast.showToast(msg: '网络错误404');
      break;
    case 413:
      Fluttertoast.showToast(msg: '上传文件太大');
      break;
    case ErrorCode.NETWORK_TIMEOUT:
      //超时
      Fluttertoast.showToast(msg: '网络超时');
      break;
    case ErrorCode.EXPIRED:
      //超时
      // Fluttertoast.showToast(msg: 'xxx');
      break;
    default:
      // Fluttertoast.showToast(msg: '网络请求失败');
      break;
  }
}

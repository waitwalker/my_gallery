import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/flu_app.dart';



void reportErrorAndLog(FlutterErrorDetails details) {
  ///上报错误和日志逻辑
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

  runApp(FluApp());
}


import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinksManager {
  static StreamSubscription? _sub;
  static StreamSubscription? _subUri;

  /// methodName handleInitialLink
  /// description 处理初始化时候的scheme & url & params
  /// date 2022/3/28 12:26 下午
  /// author LiuChuanan
  static handleInitialLink() async {
    String? initialLink;
    try {
      initialLink = await getInitialLink();
      print("传递进来的链接：$initialLink");
      if (initialLink != null) {
        /// 处理页面跳转
        print("初始化link:$initialLink");
      }
    } on PlatformException {
      initialLink = "";
    } on FormatException {
      initialLink = "";
    }
  }

  /// methodName handleIncomingLinks
  /// description 处理App打开状态下的跳转
  /// date 2022/3/28 12:31 下午
  /// author LiuChuanan
  static handleIncomingLinks() async {
    _sub = linkStream.listen((event) {
      /// 处理跳转
      print("App 打开状态下传进来的link:$event");
    },
      onError: (error){},
      onDone: (){},
      cancelOnError: false,
    );
  }

  /// methodName handleInitialUri
  /// description 处理App未打开状态下Uri
  /// date 2022/3/28 1:30 下午
  /// author LiuChuanan
  static handleInitialUri() async {
    Uri? initialUri;
    try {
      initialUri = await getInitialUri();
      if (initialUri != null) {
        /// 处理页面跳转
      }
    } on PlatformException {
      print("initialUri object");
    } on FormatException catch(err) {
      print("initialUri err:$err");
    }
  }

  /// methodName handleIncomingUri
  /// description 处理App打开状态下的Uri
  /// date 2022/3/28 1:32 下午
  /// author LiuChuanan
  static handleIncomingUri() async {
    _subUri = uriLinkStream.listen((event) {
      /// 处理页面跳转

    }, onDone: (){

    }, onError: (error){

    }, cancelOnError: false,);
  }

  /// methodName removeLinkStreamListener
  /// description 移除Link监听
  /// date 2022/3/28 1:35 下午
  /// author LiuChuanan
  static removeLinkStreamListener() async {
    if (_sub != null) {
      _sub?.cancel();
    }
  }

  /// methodName removeUriStreamListener
  /// description 移除Uri监听
  /// date 2022/3/28 1:35 下午
  /// author LiuChuanan
  static removeUriStreamListener() async {
    if (_subUri != null) {
      _subUri?.cancel();
    }
  }

}
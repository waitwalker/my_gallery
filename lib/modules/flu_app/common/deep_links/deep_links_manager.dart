
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

  /// methodName removeInitialLinkStreamListener
  /// description 移除监听
  /// date 2022/3/28 1:35 下午
  /// author LiuChuanan
  static removeInitialLinkStreamListener() async {
    if (_sub != null) {
      _sub?.cancel();
    }
  }

  /// methodName removeIncomingLinkStreamListener
  /// description 移除监听
  /// date 2022/3/28 1:35 下午
  /// author LiuChuanan
  static removeIncomingLinkStreamListener() async {
    if (_subUri != null) {
      _subUri?.cancel();
    }
  }

}
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/modules/flu_app/common/dialog/dialog.dart';
import 'package:url_launcher/url_launcher.dart';


/// methodName CommonEventManager
/// description 通用事件管理类 原则各个事件尽量隔离，处理各自业务，不要耦合，给外部调用提供方便的接口
/// 分为几大类：
/// 1.弹窗相关；
/// 2.打开长文本；
/// 3.打开游戏相关；
/// 4.打开原生页面相关；
/// 5.打开外部浏览器；
/// 6.应用内打开Webview；
/// 7.打开广告
/// 8.打开Facebook粉丝页，待调研，或通过打开网址方式完成（目前文档还待定）
/// 9.打开Whatsapp聊天窗口，待调研，或通过打开网址方式完成（目前文档还待定）
/// date 2022/3/17 6:36 下午
/// author LiuChuanan
class CommonEventManager {

  /// methodName coinEventAction
  /// description 金币弹窗事件
  /// date 2022/3/18 10:00 上午
  /// author LiuChuanan
  static coinEventAction({
    required BuildContext context,
    required String title,
    required String content,
    required String subTitle,
    required String buttonTitle,
    Function()? onTap
  }){
    DialogManager.showDialogType(
      context,
      dialogType: 1,
      title: title,
      content: content,
      subTitle: subTitle,
      buttonTitle: buttonTitle,
      imagePath: "static/images/dialog_bg_coin.webp",
      eventAction1: (){
        Navigator.pop(context);
      },
      eventAction2: onTap,
    );
  }

  /// methodName redPacketEventAction
  /// description 红包券弹窗事件
  /// date 2022/3/18 10:22 上午
  /// author LiuChuanan
  static redPacketEventAction({
    required BuildContext context,
    required String title,
    required String content,
    required String subTitle,
    required String buttonTitle,
    Function()? onTap
  }){
    DialogManager.showDialogType(
      context,
      dialogType: 2,
      title: title,
      content: content,
      subTitle: subTitle,
      buttonTitle: buttonTitle,
      imagePath: "static/images/dialog_bg_red_packet.webp",
      eventAction1: (){
        Navigator.pop(context);
      },
      eventAction2: onTap,
    );
  }

  /// methodName rewardEventAction
  /// description 图片弹窗事件
  /// date 2022/3/18 10:30 上午
  /// author LiuChuanan
  static rewardEventAction({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonTitle,
    required String imagePath,
    Function()? onTap
  }){
    DialogManager.showDialogType(
      context,
      dialogType: 3,
      title: title,
      content: content,
      buttonTitle: buttonTitle,
      imagePath: imagePath,
      eventAction1: (){
        Navigator.pop(context);
      },
      eventAction2: onTap,
    );
  }

  /// methodName optionalUpdateEventAction
  /// description 非强制版本更新弹窗事件
  /// date 2022/3/18 10:35 上午
  /// author LiuChuanan
  static optionalUpdateEventAction({
    required BuildContext context,
    required String title,
    required String content,
    Function()? noUpdateOnTap,
    Function()? updateOnTap
  }) {
    DialogManager.showDialogType(
      context,
      dialogType: 4,
      title: title,
      content: content,
      eventAction1: noUpdateOnTap,
      eventAction2: updateOnTap
    );
  }

  /// methodName forceUpdateEventAction
  /// description 强制版本更新事件
  /// date 2022/3/18 10:39 上午
  /// author LiuChuanan
  static forceUpdateEventAction({
    required BuildContext context,
    required String title,
    required String content,
    Function()? updateOnTap
  }) {
    DialogManager.showDialogType(
      context,
      dialogType: 5,
      title: title,
      content: content,
      eventAction2: updateOnTap
    );
  }

  /// methodName textEventAction
  /// description 文本事件
  /// date 2022/3/17 7:00 下午
  /// author LiuChuanan
  static textEventAction({
    required BuildContext context,
    required String content
  }) {
    DialogManager.showDialogType(
      context,
      dialogType: 6,
      content: content,
    );
  }

  /// methodName imageEventAction
  /// description 图片弹窗封装
  /// date 2022/3/21 5:56 下午
  /// author LiuChuanan
  static imageEventAction({
    required BuildContext context,
    required String imagePath,
    Function()? closeAction,
    Function()? eventAction,
  }){
    DialogManager.showDialogType(
      context,
      dialogType: 7,
      imagePath: imagePath,
      eventAction1: closeAction,
      eventAction2: eventAction
    );
  }

  /// methodName textPageAction
  /// description 跳转到通用文本页面
  /// date 2022/3/18 2:44 下午
  /// author LiuChuanan
  static textPageAction({
    required BuildContext context,
    String? title,
    required String content
  }) {
    Map<String, dynamic> params = HashMap();
    params["title"] = title ?? "";
    params["content"] = content;
    // Routes.navigateTo(context, Routes.commonTextPage, params: params);
  }

  /// methodName nativePageAction
  /// description 跳转到原生页面
  /// date 2022/3/18 2:46 下午
  /// author LiuChuanan
  static nativePageAction({
    required BuildContext context,
    required String page,
    Map<String, dynamic>? params
  }) {
    // Routes.navigateTo(context, page, params: params);
  }

  /// methodName openExternalUrlAction
  /// description 打开外部网址事件
  /// date 2022/3/18 2:48 下午
  /// author LiuChuanan
  static openExternalUrlAction({required String url}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "URL打不开");
    }
  }

  /// methodName openInternalAction
  /// description 打开内部浏览器事件
  /// date 2022/3/21 3:49 下午
  /// author LiuChuanan
  static openInternalAction({
    required BuildContext context,
    String? url,
    String? title
  }) {
    // WebViewArguments arguments = WebViewArguments(url,title: title);
    // Routes.navigateTo(context, Routes.customWebView, routeSettings: RouteSettings(
    //   arguments: arguments,
    // ));
  }

  /// methodName openADAction
  /// description 打开广告事件
  /// date 2022/3/21 3:52 下午
  /// author LiuChuanan
  static openADAction({
    required BuildContext context,
  }){
    Fluttertoast.showToast(msg: "打开广告");
  }

  /// methodName openFacebookAction
  /// description 打开Facebook事件预留
  /// date 2022/3/21 3:54 下午
  /// author LiuChuanan
  static openFacebookAction({
    required BuildContext context,
  }){
    Fluttertoast.showToast(msg: "打开Facebook");
  }

  /// methodName openWhatsappAction
  /// description 打开Whatsapp事件预留
  /// date 2022/3/21 3:54 下午
  /// author LiuChuanan
  static openWhatsappAction({
    required BuildContext context,
  }){
    Fluttertoast.showToast(msg: "打开Whatsapp");
  }

}
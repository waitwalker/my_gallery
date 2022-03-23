import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/common_tool_manager/common_tool_manager.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';

/// ********** 轻量webview *********
///
/// @name WebviewPage
/// @description 通用网页页面
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class LightWebviewPage extends StatefulWidget {
  final String url;
  Map<String, String>? headers = {};
  final String? title;
  final bool isXueAn;
  final Tasks? task;

  LightWebviewPage(this.url, {this.headers, this.title, this.isXueAn = false, this.task});

  @override
  _LightWebviewPageState createState() => _LightWebviewPageState(url, headers: headers);
}

class _LightWebviewPageState extends State<LightWebviewPage> {
  var url;

  Map<String, String>? headers;

  FlutterWebviewPlugin? webviewPlugin;

  _LightWebviewPageState(this.url, {this.headers});

  @override
  void initState() {
    super.initState();
    webviewPlugin = FlutterWebviewPlugin();
    webviewPlugin!.onDestroy.listen((_) {
      debugLog('!!!');
    } as void Function(Null)?);
    webviewPlugin!.onBack.listen((_) {
      Navigator.pop(context);
    } as void Function(Null)?);

    _taskStudyStateFetch();
  }

  ///
  /// @description 提交任务学习记录
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 11/13/20 3:57 PM
  ///
  _taskStudyStateFetch() async{
    if (widget.task != null && widget.task!.isFinish == 0) {
      await DaoManager.fetchMyPlanTaskFinishLog(widget.task!.taskId, widget.task!.resourceId);
    }
  }

  @override
  void dispose() {

    debugLog('DISPOSE!!!');
    webviewPlugin!.close();
    webviewPlugin!.dispose();
    webviewPlugin = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebviewScaffold(
        scrollBar: false,
        headers: headers,
        url: url,
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        withJavascript: true,
        clearCookies: true,
        clearCache: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          title: new Text(widget.title ?? 'webview course'),
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            _rightItem(),
          ],
        ),
      );
    } else {
      return WebviewScaffold(
        scrollBar: false,
        headers: headers,
        url: url,
        withJavascript: true,
        clearCookies: true,
        clearCache: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          title: new Text(widget.title ?? 'webview course'),
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            _rightItem(),
          ],
        ),
      );
    }
  }

  ///
  /// @name _rightItem
  /// @description 学案下载
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020/6/24
  ///
  Widget _rightItem() {
    if (widget.isXueAn) {
      return InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("下载"),
            Padding(padding: EdgeInsets.only(right: 10)),
          ],
        ),
        onTap: (){
          if (widget.url.contains("furl=")) {
            List urls = widget.url.split("furl=");
            print("学案截串后结果:$urls");
            if ( urls != null && urls.length > 0) {
              CommonToolManager.downloadXueAnFile(urls.last, fullUrl: widget.url);
            } else {
              Fluttertoast.showToast(msg: "该学案不能下载");
            }
          } else {
            Fluttertoast.showToast(msg: "该学案不能下载");
          }
        },
      );
    } else {
      return Container();
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

//////  ********** 这个webview用于微课中练习/练习任务(包括1)计划;2)诊学练测模式;3)旧的章节模式)中用到的 ******* /////////
/// 这个会先判断是否是管控设备, 如果是管控设备调用的flutter_webview_plugin, 非管控设备调用的是webview_flutter
///
/// @name MicrocourseWebPage
/// @description 做题web页面
/// @author waitwalker
/// @date 2020-01-11
/// 11
// ignore: must_be_immutable
class MicrocourseWebPage extends StatefulWidget {
  final String initialUrl;
  /// 右侧按钮事件类型
  num actionT;
  num? resourceId;
  String? resourceName;
  bool isReport;
  bool isAb;
  String? srcABPaperQuesIds;
  final Set<JavascriptChannel>? javascriptChannels;
  Tasks? task;
  int? materialid;
  int? nodeid;
  int? level;
  bool isType;
  /// 是否是诊学练测中,是的话:1诊,0学=>微课中练习
  int? isdiagnosis;

  /// 0 没有右侧; 1 练习 演草本, 答题卡; 2 查看报告; 3遇到错误 刷新按钮
  /// [isAb]true 如果是AB卷，反之false
  /// [srcABPaperQuesIds]只有在[isAb]为true才有效
  MicrocourseWebPage({
    Key? key,
    required this.resourceId,
    required this.resourceName,
    required this.initialUrl,
    this.javascriptChannels,
    this.isReport = false,
    this.isAb = false,
    this.srcABPaperQuesIds,
    this.task,
    this.materialid,
    this.level,
    this.nodeid,
    this.isdiagnosis,
    this.actionT = 0,
    this.isType = false,
  }) : super(key: key);

  @override
  _MicrocourseWebPageState createState() => _MicrocourseWebPageState();
}

class _MicrocourseWebPageState extends State<MicrocourseWebPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool isLoading = true;
  int actionType = 0;
  late FlutterWebviewPlugin flutterWebviewPlugin;

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'native',
        onMessageReceived: (JavascriptMessage message) {
          onJsCallback(message.message);
        });
  }

  @override
  void initState() {

    Future.delayed(Duration(seconds: 1), (){
      setState(() {
        isLoading = false;
      });
    });
    if (SingletonManager.sharedInstance!.isGuanKong!) {
      actionType = widget.actionT as int;
      flutterWebviewPlugin = FlutterWebviewPlugin();
      // HACK of issue: https://github.com/fluttercommunity/flutter_webview_plugin/issues/162
      flutterWebviewPlugin.onDestroy.listen((_) {
        flutterWebviewPlugin.dispose();
      } as void Function(Null)?);

      /// 监听加载状态
      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.shouldStart) {
          print("应该加载");
        } else if (viewState.type == WebViewState.startLoad) {
          print("开始加载");
        } else if (viewState.type == WebViewState.finishLoad) {
          print("网页加载完成");
        }
      });

      /// 监听加载错误
      flutterWebviewPlugin.onHttpError.listen((event) {
        Fluttertoast.showToast(msg: "网页加载遇到错误,请重试!");
      });
    } else {

    }

    super.initState();
  }

  setupOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  setupOrientationPortraitUp() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    if (SingletonManager.sharedInstance!.isGuanKong!) {
      flutterWebviewPlugin.dispose();
    }
    super.dispose();
  }

  MTTJavascriptChannel _newAlertJavascriptChannel(BuildContext context) {
    return MTTJavascriptChannel(name: "native", onMessageReceived: (s){
      print("s:${s.message}");
      onNewJsMessage(s.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(widget.isReport ? '练习报告' : widget.resourceName!),
        ),
        body: Center(child: CircularProgressIndicator(),),
      );
    } else {
      if (SingletonManager.sharedInstance!.isGuanKong!) {
        var actions = <Widget>[];
        if (actionType == 0) {

        } else if (actionType == 1) {
          var action1 = InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                MyIcons.ANSWER_CARD,
                size: 20.0,
              ),
            ),
            onTap: () {
              flutterWebviewPlugin.evalJavascript('showAnswerCard()');
            },
          );
          var action2 = InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                MyIcons.PENCIL,
                size: 20.0,
              ),
            ),
            onTap: () {
              flutterWebviewPlugin.evalJavascript('showDraftCard()');
            },
          );
          actions.add(action1);
          actions.add(action2);
        } else if (actionType == 2) {

        } else if (actionType == 3) {
          var action3 = InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.refresh,
                size: 30.0,
              ),
            ),
            onTap: () {
              flutterWebviewPlugin.reloadUrl(Uri.encodeFull(widget.initialUrl));
              setState(() {
                actionType = widget.actionT as int;
              });
            },
          );
          actions.add(action3);
        }

        return WillPopScope(
          onWillPop: () async {
            flutterWebviewPlugin.evalJavascript('document.body.remove()');
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.isReport ? '练习报告' : widget.resourceName!),
              elevation: 1,
              backgroundColor: Colors.white,
              centerTitle: Platform.isIOS ? true : false,
              actions: actions,
            ),
            body: Column(
              children: <Widget>[
                SizedBox(height: 1),
                Expanded(child: setNewWebView(),)
              ],
            ),
          ),
        );
      } else {
        var actions = <Widget>[
          InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                MyIcons.ANSWER_CARD,
                size: 20.0,
              ),
            ),
            onTap: () {
              _controller.future.then((controller) {
                if (widget.isReport) {
                  controller.evaluateJavascript('showReport()');
                } else {
                  controller.evaluateJavascript('showAnswerCard()');
                }
              });
            },
          ),
        ];
        var editAction = InkWell(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              MyIcons.PENCIL,
              size: 20.0,
            ),
          ),
          onTap: () {
            _controller.future.then(
                    (controller) => controller.evaluateJavascript('showDraftCard()'));
          },
        );
        if (!widget.isReport) {
          actions.add(editAction);
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: false,
            title: Text(widget.isReport ? '练习报告' : widget.resourceName!),
            actions: actions,
          ),
          body: Container(child: setWebView()),
        );
      }
    }
  }

  /// 设置js调用flutter交互
  setNewWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebviewScaffold(
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        scrollBar: false,
        url: Uri.encodeFull(widget.initialUrl),
        javascriptChannels: <MTTJavascriptChannel>[
          _newAlertJavascriptChannel(context),
        ].toSet(),
        withJavascript: true,
        clearCookies: true,
        clearCache: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
      );
    } else{
      return WebviewScaffold(
        scrollBar: false,
        url: Uri.encodeFull(widget.initialUrl),
        javascriptChannels: <MTTJavascriptChannel>[
          _newAlertJavascriptChannel(context),
        ].toSet(),
        withJavascript: true,
        clearCookies: true,
        clearCache: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
      );
    }
  }

  void onNewJsMessage(String s) async{
    var decode = jsonDecode(s);
    if (decode['paperid'] != null) {
      var paperId = decode['paperid'].toString();
      var token = await NetworkManager.getAuthorization();
      var resourceId = widget.resourceId;
      var url;
      if (decode['taskid']!= null && decode['taskid'] == widget.task!.taskId.toString() && widget.task!.isFinish == 0) {
        _taskStudyStateFetch(paperId);
      }
      /// 练习
      if (!widget.isAb) {
        url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId';
        if (widget.task != null) {
          url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&taskid=${widget.task!.taskId}';
        }

        if (widget.isdiagnosis != null) {
          if (widget.isdiagnosis == 0) {
            url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&isdiagnosis=0&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
          } else {
            url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&isdiagnosis=1&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
          }
        }

      } else {
        // ab卷
        url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId';
        if (widget.task != null) {
          url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId&taskid=${widget.task!.taskId}';
        }

        if (widget.nodeid != null) {
          url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        }
      }
      // 去报告页，新开页面，直接加载url，android不生效
      SingletonManager.sharedInstance!.shouldRefresh = true;
      flutterWebviewPlugin.reloadUrl(url);
      setState(() {
        actionType = 0;
      });
    } else if (decode['goto'] == 'ab') {
      // ab测试
      var token = await NetworkManager.getAuthorization();
      var abpid = widget.resourceId;
      var abpname = Uri.encodeComponent(widget.resourceName!);
      var abpqids = widget.srcABPaperQuesIds;
      var url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids';
      if (widget.task != null) {
        url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids&taskid=${widget.task!.taskId}';
      }
      if (widget.nodeid != null) {
        url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
      }

      // 再次做题，本页加载
      flutterWebviewPlugin.reloadUrl(url);
      widget.isReport = false;
      setState(() {
        actionType = 1;
      });
    } else if (decode['goto'] == 'practice') {
      var token = await NetworkManager.getAuthorization();
      var resourceId = widget.resourceId;
      var url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId';
      if (widget.task != null) {
        url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&taskid=${widget.task!.taskId}';
      }

      if (widget.isdiagnosis != null) {
        if (widget.isdiagnosis == 0) {
          url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&isdiagnosis=0&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        } else {
          url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&isdiagnosis=1&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        }
      }

      // 再次做题，本页加载
      flutterWebviewPlugin.reloadUrl(url);
      //_controller.future.then((controller) => controller.loadUrl(url));
      widget.isReport = false;
      setState(() {
        actionType = 1;
      });
    } else if (decode['']) {
      print("练习任务H5返给App的内容:$decode");
    }
  }

  setWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebView(
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        initialUrl: Uri.encodeFull(widget.initialUrl),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
// DO NOT USE CACHE
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('js://webview')) {
            onJsCallback('JS调用了Flutter By navigationDelegate');
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
      );
    } else {
      return WebView(
        initialUrl: Uri.encodeFull(widget.initialUrl),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
// DO NOT USE CACHE
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('js://webview')) {
            onJsCallback('JS调用了Flutter By navigationDelegate');
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
      );
    }
  }

  Future onJsCallback(String s) async {
    var decode = jsonDecode(s);
    if (decode['paperid'] != null) {
      var paperId = decode['paperid'].toString();
      var token = await NetworkManager.getAuthorization();
      var resourceId = widget.resourceId;
      var url;
      if (decode['taskid']!= null && decode['taskid'] == widget.task!.taskId.toString() && widget.task!.isFinish == 0) {
        _taskStudyStateFetch(paperId);
      }
      /// 练习
      if (!widget.isAb) {
        url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId';
        if (widget.task != null) {
          url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&taskid=${widget.task!.taskId}';
        }

        if (widget.isdiagnosis != null) {
          if (widget.isdiagnosis == 0) {
            url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&isdiagnosis=0&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
          } else {
            url = '${APIConst.practiceHost}/report.html?token=$token&resourceid=$resourceId&paperid=$paperId&isdiagnosis=1&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
          }
        }

      } else {
        // ab卷
        url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId';
        if (widget.task != null) {
          url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId&taskid=${widget.task!.taskId}';
        }

        if (widget.nodeid != null) {
          url = '${APIConst.practiceHost}/abreport.html?token=$token&abpid=$resourceId&paperid=$paperId&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        }
      }
      // 去报告页，新开页面，直接加载url，android不生效
      if (Platform.isIOS) {
        SingletonManager.sharedInstance!.shouldRefresh = true;
        _controller.future.then((controller) => controller.loadUrl(url));
      } else {
        SingletonManager.sharedInstance!.shouldRefresh = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return MicrocourseWebPage(
              initialUrl: url,
              isReport: true,
              resourceId: widget.resourceId,
              resourceName: widget.resourceName,
              isAb: widget.isAb,
              srcABPaperQuesIds: widget.srcABPaperQuesIds,
            nodeid: widget.nodeid,
            level: widget.level,
            materialid: widget.materialid,
            isdiagnosis: widget.isdiagnosis,
          );
        }));
      }
    } else if (decode['goto'] == 'ab') {
      // ab测试
      var token = await NetworkManager.getAuthorization();
      var abpid = widget.resourceId;
      var abpname = Uri.encodeComponent(widget.resourceName!);
      var abpqids = widget.srcABPaperQuesIds;
      var url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids';
      if (widget.task != null) {
        url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids&taskid=${widget.task!.taskId}';
      }
      if (widget.nodeid != null) {
        url = '${APIConst.practiceHost}/ab.html?token=$token&abpid=$abpid&abpname=$abpname&abpqids=$abpqids&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
      }

      // 再次做题，本页加载
      _controller.future.then((controller) => controller.loadUrl(url));
      widget.isReport = false;
      setState(() {});
    } else if (decode['goto'] == 'practice') {
      var token = await NetworkManager.getAuthorization();
      var resourceId = widget.resourceId;
      var url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId';
      if (widget.task != null) {
        url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&taskid=${widget.task!.taskId}';
      }

      if (widget.isdiagnosis != null) {
        if (widget.isdiagnosis == 0) {
          url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&isdiagnosis=0&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        } else {
          url = '${APIConst.practiceHost}/practice.html?token=$token&resourceid=$resourceId&isdiagnosis=1&materialid=${widget.materialid}&nodeid=${widget.nodeid}&level=${widget.level}';
        }
      }

      // 再次做题，本页加载
      _controller.future.then((controller) => controller.loadUrl(url));
      widget.isReport = false;
      setState(() {});
    } else if (decode['']) {
      print("练习任务H5返给App的内容:$decode");
    }
  }

  ///
  /// @description 提交任务学习记录
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 11/13/20 3:57 PM
  ///
  _taskStudyStateFetch(var paperId) async{
    if (widget.task != null && widget.task!.isFinish == 0) {
      await DaoManager.fetchMyPlanTaskFinishLog(widget.task!.taskId, paperId);
    }
  }
}

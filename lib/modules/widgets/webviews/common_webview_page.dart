import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_gallery/common/common_tool_manager/common_tool_manager.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/network/network_manager.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/date/doc_timer.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/ett_pdf_model.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/test_paper_list_model.dart';
import 'package:my_gallery/modules/widgets/pdf/pdf_page.dart';
import 'package:my_gallery/modules/widgets/alert/select_question_prompt.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:open_file/open_file.dart';
import 'package:share_extend/share_extend.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'light_webview_page.dart';
import 'package:redux/redux.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import '../loading/loading_view.dart';

/// 通用webview 组件 用于常规网页浏览等
/// 类型:
/// type == 0 通用 自带刷新
/// type == 1 错题本 系统错题/数校错题
/// type == 21 单元质检做题详情
/// type == 22 单元质检错题本
/// type == 3 office类型文档预览 包括:下载,分享,其他应用打开
/// type == 31 office类型文档预览 包括:分享,其他应用打开,主要应用在我的下载页面
/// type == 41 智能题库中章节练习 章节练习
/// type == 42 智能题库中历年真题做题
/// type == 43 智能题库中历年真题结果
///
/// @name CommonWebview
/// @description 通用Webview 组件
/// @author waitwalker
/// @date 2020-01-10
///
class CommonWebviewPage extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<JavascriptChannel>? javascriptChannels;
  final Widget? action;
  final Tasks? task;
  final int pageType;
  final DataSource? dataSource;
  final int? courseId;

  /// 错题本用到字段
  final int? subjectId;
  final bool fromShuXiao;
  final String? downloadUrl;
  final String? resId;
  final num? realPaperId;
  final String? paperName;

  final bool showBack;

  const CommonWebviewPage({
    Key? key,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.action,
    this.task,
    this.pageType = 0,
    this.subjectId,
    this.fromShuXiao = false,
    this.dataSource,
    this.downloadUrl,
    this.resId,
    this.realPaperId,
    this.paperName,
    this.courseId,
    this.showBack = false,
  }) : super(key: key);

  @override
  _CommonWebviewPageState createState() => _CommonWebviewPageState();
}

class _CommonWebviewPageState extends State<CommonWebviewPage> with SingleTickerProviderStateMixin {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  var _index = 0;
  bool isLoading = true;
  int actionType = 0;
  FlutterWebviewPlugin? flutterWebviewPlugin;
  bool hasError = true;
  int type = 0;

  /// 错题本用到属性
  bool showMenu = false;
  var score;

  /// 单元质检相关
  // 是否显示提交按钮
  bool showSubmitButton = false;

  /// 只看未消错
  bool onlyCorrected = false;
  bool isFinishedLoading = false;

  // 消错和未消错数量
  String totalCount = "";
  String correctCount = "";

  // 显示查看未消错按钮
  bool showCorrectButton = false;

  @override
  void initState() {
    if (widget.pageType == 3 && widget.downloadUrl != null) {
      print("学案下载地址:${widget.downloadUrl}");
      CommonToolManager.downloadXueAnFile(widget.downloadUrl!, fullUrl: Uri.encodeFull(widget.initialUrl!), canShowToast: false, courseTitle: widget.title);
      DocTimer.startReportTimer(context, resId: widget.resId);
    }

    super.initState();
    type = widget.pageType;
    _taskStudyStateFetch();

    Future.delayed(Duration(seconds: 1), (){
      setState(() {
        isLoading = false;
      });
    });
    if (SingletonManager.sharedInstance!.isGuanKong!) {
      if (type == 22) {
        totalCount = "${widget.dataSource!.totalCnt}";
        correctCount = "${widget.dataSource!.totalCnt! - widget.dataSource!.surplusCnt!}";
      }
      flutterWebviewPlugin = FlutterWebviewPlugin();
      flutterWebviewPlugin!.onDestroy.listen((_) {
        flutterWebviewPlugin!.dispose();
      } as void Function(Null)?);

      /// 监听加载状态
      flutterWebviewPlugin!.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.shouldStart) {
          print("应该加载");
        } else if (viewState.type == WebViewState.startLoad) {
          print("定制机页面开始加载");
        } else if (viewState.type == WebViewState.finishLoad) {
          print("定制机页面网页加载完成");
        }
      });

      /// 监听加载错误
      flutterWebviewPlugin!.onHttpError.listen((event) {
        //Fluttertoast.showToast(msg: "网页加载遇到错误,请重试!");
        setState(() {
          hasError = true;
        });
      });
    } else {

    }
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
          title: Text(widget.title ?? ""),
        ),
        body: Center(child: CircularProgressIndicator(),),
      );
    } else {
      if (SingletonManager.sharedInstance!.isGuanKong!) {
        return WillPopScope(
          onWillPop: () async {

            if (type == 41 || type == 42 || type == 43) {
              return true;
            }

            bool canGoBack = await flutterWebviewPlugin!.canGoBack();
            if (canGoBack) {
              await flutterWebviewPlugin!.goBack();
              return false;
            }
            flutterWebviewPlugin!.evalJavascript('document.body.remove()');
            return true;
          },
          child: Scaffold(
            appBar: setupAppBar(),
            body: Column(
              children: <Widget>[
                SizedBox(height: 1),
                Expanded(child: setNewWebView(),)
              ],
            ),
          ),
        );
      } else {
        return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
          return WillPopScope(
            onWillPop: () async {
              _controller.future.then((controller) {
                controller.evaluateJavascript('document.body.remove()');
              });
              var ctl = await _controller.future;
              if (await ctl.canGoBack()) {
                ctl.goBack();
                return false;
              }
              return true;
            },
            child: Scaffold(
              appBar: setupAppBar(),
              resizeToAvoidBottomInset: true,
              body: Container(
                child: IndexedStack(index: _index, children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                  setWebView(),
                ]),
              ),
            ),
          );
        });
      }
    }
  }

  ///
  /// @description 设置导航相关 这里区分定制机&非定制机
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/8/21 10:54 AM
  ///
  AppBar setupAppBar() {
    /// 管控设备
    if (SingletonManager.sharedInstance!.isGuanKong!) {
      /// 错题本
      if (type == 1) {
        Map subjects = {
          1: MTTLocalization.of(context)!.currentLocalized!.commonChinese,
          2: MTTLocalization.of(context)!.currentLocalized!.commonMathematics,
          3: MTTLocalization.of(context)!.currentLocalized!.commonEnglish,
          4: MTTLocalization.of(context)!.currentLocalized!.commonPhysical,
          5: MTTLocalization.of(context)!.currentLocalized!.commonChemistry,
          6: MTTLocalization.of(context)!.currentLocalized!.commonHistory,
          7: MTTLocalization.of(context)!.currentLocalized!.commonBiology,
          8: MTTLocalization.of(context)!.currentLocalized!.commonGeography,
          9: MTTLocalization.of(context)!.currentLocalized!.commonPolitics,
          10: '科学',
        };
        String? title = subjects[widget.subjectId];
        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title ?? "错题本"),
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 20,top: 20),
                child: Text(showMenu ?  MTTLocalization.of(context)!.currentLocalized!.errorBookPageCancel! : MTTLocalization.of(context)!.currentLocalized!.errorBookPageChoose!,style: TextStyle(fontSize: 15, color: Color(0xff757575),),),
              ),
              onTap: (){
                _newRefreshNavigationBar(true, 1);
              },
            ),
          ],
        );
      } else if (type == 21) {
        String title = widget.title ?? '';
        return AppBar(
          actions: <Widget>[showSubmitButton ? Padding(padding: EdgeInsets.only(right: 20), child: Center(child: InkWell(
            child: Text("提交", style: TextStyle(fontSize: 14, color: Color(0xff757575),),),
            onTap: (){
              flutterWebviewPlugin!.evalJavascript("postPaperQueue()");
            },
          ),),) : Container(),],
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      } else if(type == 22) {
        String title = "共计错题: $totalCount  已经消错: $correctCount";
        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title ?? "错题本", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          centerTitle: false,
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 20,),
                child: showCorrectButton ? Center(child: Text(onlyCorrected ?  "全部错题" : "只看未消错", style: TextStyle(fontSize: 14, color: Color(0xff757575),),),) : Container(),
              ),
              onTap: (){
                _newRefreshNavigationBar(true, 22);
              },
            ),
          ],
        );
      } else if (type == 3) {
        return AppBar(
            title: Text(widget.title ?? '',style: TextStyle(fontSize: 14),),
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            actions: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (widget.downloadUrl != null) ...[
                      InkWell(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('static/images/download.png',
                                  width: 36, height: 36),
                              Text('下载', style: textStyleMini)
                            ],
                          ),
                          onTap: () async {
                            final dir = await CommonToolManager.localDirectory();
                            String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                            String filePath = '$dir/$fileName';
                            File file = File(filePath);
                            bool isExist = await file.exists();
                            if (isExist) {
                              Fluttertoast.showToast(msg: '已下载，可以在我的下载查看');
                            } else {
                              print("学案下载地址:${widget.downloadUrl}");
                              CommonToolManager.downloadXueAnFile(widget.downloadUrl!, fullUrl: Uri.encodeFull(widget.initialUrl!), canShowToast: true, courseTitle: widget.title);
                            }
                          }),
                      const SizedBox(width: 17),
                    ],
                    InkWell(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('static/images/qita.png',
                                width: 30, height: 30),
                            Text('其他应用打开', style: textStyleMini)
                          ],
                        ),
                        onTap: () async {
                          final dir = await CommonToolManager.localDirectory();
                          String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                          String filePath = '$dir/$fileName';
                          File file = File(filePath);
                          bool isExist = await file.exists();
                          if (isExist) {
                            if (Platform.isAndroid) {
                              final result = await OpenFile.open(filePath);
                              print("文件打开结果:$result");
                            } else {
                              final result = await OpenFile.open(filePath);
                              print("文件打开结果:$result");
                            }
                          } else {
                            Fluttertoast.showToast(msg: "文件不存在,暂不能分享,请先下载再分享!");
                          }
                        }),
                    const SizedBox(width: 17),

                    InkWell(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('static/images/send.png',
                                width: 30, height: 30),
                            Text('发送至电脑', style: textStyleMini)
                          ],
                        ),
                        onTap: () async {
                          /// 分享文件
                          File file = await CommonToolManager.localFile(widget.downloadUrl!);
                          if (!await file.exists()) {
                            await file.create(recursive: true);
                            file.writeAsStringSync("test for share documents file");
                          }
                          ShareExtend.share(file.path, "file");
                        }),
                    const SizedBox(width: 17),
                  ]),
            ]);
      } else if (type == 31) {
        return AppBar(
            title: Text(widget.title ?? '',style: TextStyle(fontSize: 14),),
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            actions: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('static/images/qita.png',
                                width: 30, height: 30),
                            Text('其他应用打开', style: textStyleMini)
                          ],
                        ),
                        onTap: () async {
                          final dir = await CommonToolManager.localDirectory();
                          String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                          String filePath = '$dir/$fileName';
                          File file = File(filePath);
                          bool isExist = await file.exists();
                          if (isExist) {
                            if (Platform.isAndroid) {
                              final result = await OpenFile.open(filePath);
                              print("文件打开结果:$result");
                            } else {
                              final result = await OpenFile.open(filePath);
                              print("文件打开结果:$result");
                            }
                          } else {
                            Fluttertoast.showToast(msg: "文件不存在,暂不能分享,请先下载再分享!");
                          }
                        }),
                    const SizedBox(width: 17),

                    InkWell(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('static/images/send.png',
                                width: 30, height: 30),
                            Text('发送至电脑', style: textStyleMini)
                          ],
                        ),
                        onTap: () async {
                          /// 分享文件
                          File file = await CommonToolManager.localFile(widget.downloadUrl!);
                          if (!await file.exists()) {
                            await file.create(recursive: true);
                            file.writeAsStringSync("test for share documents file");
                          }
                          ShareExtend.share(file.path, "file");
                        }),
                    const SizedBox(width: 17),
                  ]),
            ]);
      } else if(type == 41) {
        String title = widget.title ?? '';
        return AppBar(
          actions: <Widget>[showSubmitButton ? Padding(padding: EdgeInsets.only(right: 20), child: Center(child: InkWell(
            child: Text("提交", style: TextStyle(fontSize: 14, color: Color(0xff757575),),),
            onTap: (){
              flutterWebviewPlugin!.evalJavascript("postPaperQueue()");
            },
          ),),) : Container(),],
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      } else if(type == 42) {
        String title = widget.title ?? '';
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
              flutterWebviewPlugin!.evalJavascript("showAnswerCard()");
            },
          ),
          InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                MyIcons.PENCIL,
                size: 20.0,
              ),
            ),
            onTap: () {
              flutterWebviewPlugin!.evalJavascript("showDraftCard()");
            },
          ),
        ];
        return AppBar(
          actions: actions,
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      } else if(type == 43) {
        String title = widget.title ?? '';
        return AppBar(
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      } else {
        var actions = <Widget>[];
        if (hasError) {
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
              flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(widget.initialUrl!));
              setState(() {
                /// 没有错误
                hasError = true;
              });
            },
          );
          actions.add(action3);
        }
        return AppBar(
          leading: widget.showBack ? InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () async {
              bool canGoBack = await flutterWebviewPlugin!.canGoBack();
              if (canGoBack) {
                await flutterWebviewPlugin!.goBack();
              }
            },
          ): null,
          title: Text(widget.title!),
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: Platform.isIOS ? true : false,
          actions: actions,
        );
      }
    } else {
      if (type == 1) {
        Map subjects = {
          1: MTTLocalization.of(context)!.currentLocalized!.commonChinese,
          2: MTTLocalization.of(context)!.currentLocalized!.commonMathematics,
          3: MTTLocalization.of(context)!.currentLocalized!.commonEnglish,
          4: MTTLocalization.of(context)!.currentLocalized!.commonPhysical,
          5: MTTLocalization.of(context)!.currentLocalized!.commonChemistry,
          6: MTTLocalization.of(context)!.currentLocalized!.commonHistory,
          7: MTTLocalization.of(context)!.currentLocalized!.commonBiology,
          8: MTTLocalization.of(context)!.currentLocalized!.commonGeography,
          9: MTTLocalization.of(context)!.currentLocalized!.commonPolitics,
          10: '科学',
        };
        String? title = subjects[widget.subjectId];
        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title ?? "错题本"),
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 20,top: 20),
                child: Text(showMenu ?  MTTLocalization.of(context)!.currentLocalized!.errorBookPageCancel! : MTTLocalization.of(context)!.currentLocalized!.errorBookPageChoose!,style: TextStyle(fontSize: 15, color: Color(0xff757575),),),
              ),
              onTap: (){
                _refreshNavigationBar(true, 1);
              },
            ),
          ],
        );
      } else if (type == 21) {
        String title = widget.title ?? '';
        return AppBar(
          actions: <Widget>[showSubmitButton ? Padding(padding: EdgeInsets.only(right: 20), child: Center(child: InkWell(
            child: Text("提交", style: TextStyle(fontSize: 14, color: Color(0xff757575),),),
            onTap: (){
              _controller.future.then((controller){
                controller.evaluateJavascript('postPaperQueue()');
              });
            },
          ),),) : Container(),],
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      } else if (type == 3) {
        return AppBar(
            title: Text(widget.title ?? '',style: TextStyle(fontSize: 14),),
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            actions: <Widget>[
              InkWell(
                  child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.menu)),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 155,
                        padding: EdgeInsets.only(left: 20, right: 20),
                        // alignment: Alignment.center,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              if (widget.downloadUrl != null) ...[
                                InkWell(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('static/images/download.png',
                                            width: 50, height: 50),
                                        const SizedBox(height: 9),
                                        Text('下载', style: textStyleMini)
                                      ],
                                    ),
                                    onTap: () async {
                                      final dir = await CommonToolManager.localDirectory();
                                      String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                                      String filePath = '$dir/$fileName';
                                      File file = File(filePath);
                                      bool isExist = await file.exists();
                                      if (isExist) {
                                        Fluttertoast.showToast(msg: '已下载，可以在我的下载查看');
                                        Navigator.of(context).pop();
                                      } else {
                                        print("学案下载地址:${widget.downloadUrl}");
                                        CommonToolManager.downloadXueAnFile(widget.downloadUrl!, fullUrl: Uri.encodeFull(widget.initialUrl!), canShowToast: true);
                                        Navigator.of(context).pop();
                                      }
                                    }),
                                const SizedBox(width: 17),
                              ],
                              InkWell(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('static/images/qita.png',
                                          width: 50, height: 50),
                                      const SizedBox(height: 9),
                                      Text('其他应用打开', style: textStyleMini)
                                    ],
                                  ),
                                  onTap: () async {
                                    final dir = await CommonToolManager.localDirectory();
                                    String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                                    String filePath = '$dir/$fileName';
                                    File file = File(filePath);
                                    bool isExist = await file.exists();
                                    if (isExist) {
                                      if (Platform.isAndroid) {
                                        final result = await OpenFile.open(filePath);
                                        print("文件打开结果:$result");
                                      } else {
                                        final result = await OpenFile.open(filePath);
                                        print("文件打开结果:$result");
                                      }
                                      Navigator.of(context).pop();
                                    } else {
                                      Fluttertoast.showToast(msg: "文件不存在,暂不能分享,请先下载再分享!");
                                      Navigator.of(context).pop();
                                    }
                                  }),
                              const SizedBox(width: 17),

                              InkWell(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('static/images/send.png',
                                          width: 50, height: 50),
                                      const SizedBox(height: 9),
                                      Text('发送至电脑', style: textStyleMini)
                                    ],
                                  ),
                                  onTap: () async {
                                    /// 分享文件
                                    File file = await CommonToolManager.localFile(widget.downloadUrl!);
                                    if (!await file.exists()) {
                                      await file.create(recursive: true);
                                      file.writeAsStringSync("test for share documents file");
                                    }
                                    ShareExtend.share(file.path, "file");
                                    Navigator.of(context).pop();
                                  }),
                              const SizedBox(width: 17),
                            ]),

                      ),
                    ).then((_) {

                    });
                  })
            ]);
      } else if (type == 31) {
        return AppBar(
            title: Text(widget.title ?? '',style: TextStyle(fontSize: 14),),
            elevation: 1,
            backgroundColor: Colors.white,
            centerTitle: Platform.isIOS ? true : false,
            actions: <Widget>[
              InkWell(
                  child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.menu)),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) => Container(
                        height: 155,
                        padding: EdgeInsets.only(left: 20, right: 20),
                        // alignment: Alignment.center,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('static/images/qita.png',
                                          width: 50, height: 50),
                                      const SizedBox(height: 9),
                                      Text('其他应用打开', style: textStyleMini)
                                    ],
                                  ),
                                  onTap: () async {
                                    final dir = await CommonToolManager.localDirectory();
                                    String fileName = CommonToolManager.getFileName(widget.downloadUrl!);
                                    String filePath = '$dir/$fileName';
                                    File file = File(filePath);
                                    bool isExist = await file.exists();
                                    if (isExist) {
                                      if (Platform.isAndroid) {
                                        final result = await OpenFile.open(filePath);
                                        print("文件打开结果:$result");
                                      } else {
                                        final result = await OpenFile.open(filePath);
                                        print("文件打开结果:$result");
                                      }
                                      Navigator.of(context).pop();
                                    } else {
                                      Fluttertoast.showToast(msg: "文件不存在,暂不能分享,请先下载再分享!");
                                      Navigator.of(context).pop();
                                    }
                                  }),
                              const SizedBox(width: 17),

                              InkWell(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('static/images/send.png',
                                          width: 50, height: 50),
                                      const SizedBox(height: 9),
                                      Text('发送至电脑', style: textStyleMini)
                                    ],
                                  ),
                                  onTap: () async {
                                    /// 分享文件
                                    File file = await CommonToolManager.localFile(widget.downloadUrl!);
                                    if (!await file.exists()) {
                                      await file.create(recursive: true);
                                      file.writeAsStringSync("test for share documents file");
                                    }
                                    ShareExtend.share(file.path, "file");
                                    Navigator.of(context).pop();
                                  }),
                              const SizedBox(width: 17),
                            ]),
                      ),
                    ).then((_) {

                    });
                  })
            ]);
      } else if(type == 41) {
        String title = widget.title ?? '';
        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title ?? "错题本"),
          centerTitle: Platform.isIOS ? true : false,
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: 20,top: 20),
                child: Text(showMenu ?  MTTLocalization.of(context)!.currentLocalized!.errorBookPageCancel! : MTTLocalization.of(context)!.currentLocalized!.errorBookPageChoose!,style: TextStyle(fontSize: 15, color: Color(0xff757575),),),
              ),
              onTap: (){
                _refreshNavigationBar(true, 1);
              },
            ),
          ],
        );
      } else if(type == 42) {
        String title = widget.title ?? '';
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
                controller.evaluateJavascript('showAnswerCard()');
              });
            },
          ),
          InkWell(
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
          ),
        ];

        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title),
          centerTitle: Platform.isIOS ? true : false,
          actions: actions,
        );
      } else if(type == 43) {
        String title = widget.title ?? '';
        return AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(title),
          centerTitle: Platform.isIOS ? true : false,
        );
      } else {
        var actions = <Widget>[];
        if (hasError) {
          var action3 = InkWell(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.refresh,
                size: 30.0,
              ),
            ),
            onTap: () async{
              WebViewController ctl = await _controller.future;
              ctl.reload();
              setState(() {
                /// 没有错误
                hasError = true;
              });
            },
          );
          actions.add(action3);
        }
        String title = widget.title ?? '';
        return AppBar(
          leading: widget.showBack ? InkWell(
            child: Icon(Icons.arrow_back_ios),
            onTap: () async {
              _controller.future.then((controller) {

              });
              var ctl = await _controller.future;
              if (await ctl.canGoBack()) {
                ctl.goBack();
              }
            },
          ): null,
          actions: actions,
          centerTitle: Platform.isIOS ? true : false,
          elevation: 1,
          title: Text(title, style: TextStyle(fontSize: title.length > 15 ? 12 :  title.length > 11 ? 16: 22),),
          backgroundColor: Colors.white,
        );
      }
    }
  }

  /// 非定制机初始化webview
  setWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebView(
        initialUrl: Uri.encodeFull(widget.initialUrl!),
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        onPageFinished: (String url) {
          print('平板页面加载完成Page finished loading: $url');
          setState(() {
            _index = 1;
          });
        },
        onPageStarted: (String url){
          print('平板页面开始加载Page start loading: $url');
        },
      );
    } else {
      return WebView(
        initialUrl: Uri.encodeFull(widget.initialUrl!),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        onPageFinished: (String url) {
          print('手机页面加载完成Page finished loading: $url');
          setState(() {
            _index = 1;
          });
        },
        onPageStarted: (String url){
          print('手机页面开始加载Page start loading: $url');
        },
      );
    }
  }

  /// 非定制机 js调用flutter
  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(name: 'native', onMessageReceived: (JavascriptMessage message) async {

      print("消息message:${message.message}");
      bool type = message.message is String;
      Map? map;
      print("type:$type");
      if (message.message is String) {
        map = json.decode(message.message);
        print("map:$map");
        if (map != null) {

          /// 活动课相关
          String? downloadUrl = map["xiazai"];
          String? checkXueAn = map["xuean"];
          String? office = map["office"];
          if (downloadUrl != null) {
            print("学案下载地址:$downloadUrl");
            CommonToolManager.downloadXueAnFile(downloadUrl, fullUrl: office, courseTitle: "活动课");
          }

          if (checkXueAn != null) {
            print("查看学案的地址:$checkXueAn");
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return LightWebviewPage(checkXueAn, title: '学案');
            }));
          }

          /// 错题本相关
          if (map['qidlists'] != null) {
            List qidlists = map['qidlists'];
            List questionIds = qidlists[0];
            List quesGroupIds = qidlists[1];
            if (questionIds != null) {
              if (questionIds.length > 20) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return SelectQuestionWidget(
                        tapCallBack: () {
                          print("点击");
                          Navigator.of(context).pop();
                        },
                      );
                    });
              } else {
                _submitAndGetPdf(questionIds, quesGroupIds);
              }
            }
          } else if (map['goto'] != null) {
            if (map['goto'] == "questionbankpractice") {
              /// type 43  H5给原生传的跳转链接 这里要从43 跳转到 42
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                var url = APIConst.realQuestionPractice;
                var token = NetworkManager.getAuthorization();
                String fullURL = '$url?token=$token&realpaperid=${widget.realPaperId}&papername=${widget.paperName}&subjectid=${widget.subjectId}&courseid=${widget.courseId}';
                fullURL = fullURL.replaceAll(" ", "");
                return CommonWebviewPage(
                  subjectId: widget.subjectId,
                  paperName: widget.paperName,
                  realPaperId: widget.realPaperId,
                  title: widget.paperName,
                  initialUrl: fullURL,
                  pageType: 42,
                );})
              );

            } else {
              WebViewController ctl = await _controller.future;
              ctl.loadUrl(Uri.encodeFull(widget.initialUrl!));
            }
          }

          /// 单元质检
          String? btn = map["btn"];
          if (btn == "open") {
            setState(() {
              showSubmitButton = true;
            });
          } else if (btn == "close") {
            setState(() {
              showSubmitButton = false;
            });
          }

          int? all = map["all"];
          int? correct = map["correct"];
          if (all != null && correct != null) {
            if (all != correct) {
              showCorrectButton = true;
            } else {
              showCorrectButton = false;
            }
            setState(() {
              totalCount = all.toString();
              correctCount = correct.toString();
            });
          }

          /// type 42 用到 这时会从 42 跳转到 43
          /// 历年真题提交后 返回creatpaperid
          if (map['creatpaperid'] != null) {
            ErrorCode.errorHandleFunction(ErrorCode.SUCCESS, '可以刷新', false);
            num? creatpaperid = map["creatpaperid"];
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
              var url = APIConst.realQuestionReport;
              var token = NetworkManager.getAuthorization();
              String fullURL = '$url?token=$token&realpaperid=${widget.realPaperId}&creatpaperid=$creatpaperid&papername=${widget.paperName}';
              fullURL = fullURL.replaceAll(" ", "");
              return CommonWebviewPage(
                title: widget.paperName,
                subjectId: widget.subjectId,
                paperName: widget.paperName,
                realPaperId: widget.realPaperId,
                initialUrl: fullURL,
                pageType: 43,
              );
            }));
          }

        }
      } else if (message.message is Map) {

      }

    });
  }

  /// 定制机初始化webview
  setNewWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebviewScaffold(
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        scrollBar: false,
        url: Uri.encodeFull(widget.initialUrl!),
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
        url: Uri.encodeFull(widget.initialUrl!),
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

  ///
  /// @name _submitAndGetPdf
  /// @description 生成pdf
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-02
  ///
  void _submitAndGetPdf(List questionIds, List quesGroupIds) async {
    if (questionIds == null) {
      Fluttertoast.showToast(msg: '请先选择错题');
      return;
    }
    String ids = questionIds.join(",");
    String? groupIds;
    if (quesGroupIds != null) {
      groupIds = quesGroupIds.join(",");
    }

    /// 查询token
    String authorizationCode = await getAuthorization();

    Map<String,dynamic> parameter = (groupIds != null && groupIds.length > 0) ?  {
      "questionIds":ids,
      "questionType":widget.fromShuXiao ? 2 : 1,
      "subjectId":widget.subjectId,
      "questionsGroupIds":groupIds,
      "accessToken":authorizationCode
    } : {
      "questionIds":ids,
      "questionType":widget.fromShuXiao ? 2 : 1,
      "subjectId":widget.subjectId,
      "accessToken":authorizationCode
    };

    /// 显示加载圈
    _showLoading();

    ResponseData responseData = await DaoManager.fetchPDFURL(parameter);

    print("data:$responseData");

    /// 移除加载圈
    _hideLoading();

    if (responseData != null && responseData.model != null) {
      ETTPDFModel pdfModel = responseData.model;
      if (pdfModel.type == "success" && pdfModel.msg == "成功") {
        print("url: ${pdfModel.data!.previewUrl}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return PDFPage(pdfModel.data!.previewUrl,title: pdfModel.data!.presentationName,);
        })).then((value){
          _refreshNavigationBar(true, 1);
        });
      } else {
        Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
    }
  }

  /// 错题本用到
  ///
  /// @name _refreshNavigationBar
  /// @description 刷新导航栏
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-02
  ///
  _refreshNavigationBar(bool isTapped, int type) {
    if (type == 1 || type == 42) {
      if (isTapped) {
        setState(() {
          showMenu = !showMenu;
          if (showMenu) {
            _controller.future.then((controller){
              controller.evaluateJavascript('openedit()');
            });
          } else {
            _controller.future.then((controller){
              controller.evaluateJavascript('closeedit()');
            });
          }
        });
      } else {
        setState(() {
          showMenu = false;
          if (showMenu) {
            _controller.future.then((controller){
              controller.evaluateJavascript('openedit()');
            });
          } else {
            _controller.future.then((controller){
              controller.evaluateJavascript('closeedit()');
            });
          }
        });
      }
    } else if (type == 22) {
      if (isTapped) {
        setState(() {
          onlyCorrected = !onlyCorrected;
          if (onlyCorrected) {
            _controller.future.then((controller){
              controller.evaluateJavascript('selectNoCorrect()');
            });
          } else {
            _controller.future.then((controller){
              controller.evaluateJavascript('selectAll()');
            });
          }
        });
      } else {
        setState(() {
          onlyCorrected = false;
          if (onlyCorrected) {
            _controller.future.then((controller){
              controller.evaluateJavascript('openedit()');
            });
          } else {
            _controller.future.then((controller){
              controller.evaluateJavascript('closeedit()');
            });
          }
        });
      }
    }

  }

  /// 定制机js交互处理
  MTTJavascriptChannel _newAlertJavascriptChannel(BuildContext context) {
    return MTTJavascriptChannel(name: "native", onMessageReceived: (s) async{
      print("s:${s.message}");
      print("消息message:${s.message}");
      bool messageType = s.message is String;
      Map? map;
      print("type:$messageType");
      if (s.message is String) {
        map = json.decode(s.message);
        print("map:$map");
        if (map != null) {
          /// 活动课用到
          String? downloadUrl = map["xiazai"];
          String? checkXueAn = map["xuean"];
          String? office = map["office"];
          if (downloadUrl != null) {
            print("学案下载地址:$downloadUrl");
            CommonToolManager.downloadXueAnFile(downloadUrl, fullUrl: office);
          }

          if (checkXueAn != null) {
            print("查看学案的地址:$checkXueAn");
            flutterWebviewPlugin!.close();
            flutterWebviewPlugin!.dispose();
            flutterWebviewPlugin = null;
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return LightWebviewPage(checkXueAn, title: '学案');
            })).then((value) {
              setState(() {
                isLoading = true;
              });

              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  isLoading = false;
                  flutterWebviewPlugin = FlutterWebviewPlugin();
                  flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(widget.initialUrl!));
                });
              });
            });
          }

          /// 错题本相关
          if (map['qidlists'] != null) {
            List qidlists = map['qidlists'];
            List questionIds = qidlists[0];
            List quesGroupIds = qidlists[1];
            if (questionIds != null) {
              flutterWebviewPlugin!.hide();
              if (questionIds.length > 20) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return SelectQuestionWidget(
                        tapCallBack: () {
                          print("点击");
                          Navigator.of(context).pop();
                          flutterWebviewPlugin!.show();
                        },
                      );
                    });
              } else {
                flutterWebviewPlugin!.close();
                flutterWebviewPlugin!.dispose();
                flutterWebviewPlugin = null;
                _newSubmitAndGetPdf(questionIds, quesGroupIds);
              }
            }
          } else if (map['goto'] != null) {
            if (map['goto'] == "questionbankpractice") {
              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  type = 42;
                  flutterWebviewPlugin = FlutterWebviewPlugin();
                  var url = APIConst.realQuestionPractice;
                  var token = NetworkManager.getAuthorization();
                  String fullURL = '$url?token=$token&realpaperid=${widget.realPaperId}&papername=${widget.paperName}&subjectid=${widget.subjectId}&courseid=${widget.courseId}';
                  fullURL = fullURL.replaceAll(" ", "");
                  flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(fullURL));
                });
              });
            } else {
              Future.delayed(Duration(seconds: 1),(){
                setState(() {
                  isLoading = false;
                  flutterWebviewPlugin = FlutterWebviewPlugin();
                  flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(widget.initialUrl!));
                });
              });
            }
          }

          /// 单元质检
          String? btn = map["btn"];
          if (btn == "open") {
            setState(() {
              showSubmitButton = true;
            });
          } else if (btn == "close") {
            setState(() {
              showSubmitButton = false;
            });
          }

          int? all = map["all"];
          int? correct = map["correct"];
          if (all != null && correct != null) {
            if (all != correct) {
              showCorrectButton = true;
            } else {
              showCorrectButton = false;
            }
            setState(() {
              totalCount = all.toString();
              correctCount = correct.toString();
            });
          }

          /// type 42 用到 这时会从 42 跳转到 43
          /// 历年真题提交后 返回creatpaperid
          if (map['creatpaperid'] != null) {
            ErrorCode.errorHandleFunction(ErrorCode.SUCCESS, '可以刷新', false);
            num? creatpaperid = map["creatpaperid"];
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                type = 43;
                flutterWebviewPlugin = FlutterWebviewPlugin();
                var url = APIConst.realQuestionReport;
                var token = NetworkManager.getAuthorization();
                String fullURL = '$url?token=$token&realpaperid=${widget.realPaperId}&creatpaperid=$creatpaperid&papername=${widget.paperName}';
                fullURL = fullURL.replaceAll(" ", "");
                flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(fullURL));
              });
            });

          }
        }
      } else if (s.message is Map) {

      }
    });
  }


  /// 错题本用到
  ///
  /// @name _refreshNavigationBar
  /// @description 刷新导航栏
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-02
  ///
  _newRefreshNavigationBar(bool isTapped, int type) async{
    if (type == 1) {
      if (isTapped) {
        setState(() {
          showMenu = !showMenu;
          if (showMenu) {
            flutterWebviewPlugin!.evalJavascript("openedit()");
          } else {
            flutterWebviewPlugin!.evalJavascript("closeedit()");
          }
        });
      } else {
        setState(() {
          showMenu = false;
          if (showMenu) {
            flutterWebviewPlugin!.evalJavascript("openedit()");
          } else {
            flutterWebviewPlugin!.evalJavascript("closeedit()");
          }
        });
      }
    } else if (type == 22) {
      if (isTapped) {
        setState(() {
          onlyCorrected = !onlyCorrected;
          if (onlyCorrected) {
            flutterWebviewPlugin!.evalJavascript("selectNoCorrect()");
          } else {
            flutterWebviewPlugin!.evalJavascript("selectAll()");
          }
        });
      } else {
        setState(() {
          onlyCorrected = !onlyCorrected;
          if (onlyCorrected) {
            flutterWebviewPlugin!.evalJavascript("openedit()");
          } else {
            flutterWebviewPlugin!.evalJavascript("closeedit()");
          }
        });
      }
    }
  }

  ///
  /// @name _submitAndGetPdf
  /// @description 生成pdf
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-02
  ///
  void _newSubmitAndGetPdf(List questionIds, List quesGroupIds) async {
    if (questionIds == null) {
      Fluttertoast.showToast(msg: '请先选择错题');
      return;
    }
    String ids = questionIds.join(",");
    String? groupIds;
    if (quesGroupIds != null) {
      groupIds = quesGroupIds.join(",");
    }

    /// 查询token
    String authorizationCode = await getAuthorization();

    Map<String,dynamic> parameter = (groupIds != null && groupIds.length > 0) ?  {
      "questionIds":ids,
      "questionType":widget.fromShuXiao ? 2 : 1,
      "subjectId":widget.subjectId,
      "questionsGroupIds":groupIds,
      "accessToken":authorizationCode
    } : {
      "questionIds":ids,
      "questionType":widget.fromShuXiao ? 2 : 1,
      "subjectId":widget.subjectId,
      "accessToken":authorizationCode
    };

    /// 显示加载圈
    _showLoading();

    ResponseData responseData = await DaoManager.fetchPDFURL(parameter);

    print("data:$responseData");

    /// 移除加载圈
    _hideLoading();

    if (responseData != null && responseData.model != null) {
      ETTPDFModel pdfModel = responseData.model;
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      String officeURL = "https://vip.ow365.cn/?i=13509&ssl=1&fname=$time/&furl=${pdfModel.data!.previewUrl}";
      if (pdfModel.type == "success" && pdfModel.msg == "成功") {
        print("url: ${pdfModel.data!.previewUrl}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return PDFPage(pdfModel.data!.previewUrl,title: pdfModel.data!.presentationName, officeURL: officeURL);
        })).then((value){
          setState(() {
            isLoading = true;
          });

          Future.delayed(Duration(seconds: 1),(){
            setState(() {
              isLoading = false;
              flutterWebviewPlugin = FlutterWebviewPlugin();
              flutterWebviewPlugin!.reloadUrl(Uri.encodeFull(widget.initialUrl!));
              showMenu = false;
            });
          });
        });
      } else {
        Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
      }
    } else {
      Fluttertoast.showToast(msg: '您的作业被小怪兽吃了，再生成一次吧。',gravity: ToastGravity.CENTER);
    }
  }

  ///获取授权token
  static getAuthorization() {
    var json = SharedPrefsUtils.getString(APIConst.LOGIN_JSON, '{}')!;
    var ccLoginModel = LoginModel.fromJson(jsonDecode(json));
    String? token = ccLoginModel.access_token;
    if (token == null) {
      String basic = APIConst.basicToken;
      if (basic == null) {
        //提示输入账号密码
      } else {
        //通过 basic 去获取token，获取到设置，返回token
        return "Basic $basic";
      }
    } else {
      return token;
    }
  }

  ///
  /// @name _showLoading 显示加载圈
  /// @description
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-31
  ///
  _showLoading() {
    /// 1.上传所选的题目id
    /// 2.获取组装完的pdf文档
    /// 3.刷一下当前页面状态
    if (Platform.isIOS) {
      showDialog(context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingView();
        },
      );
    } else {
      showDialog(context: context,
        barrierDismissible: false,
        builder: (context) {
          return LoadingView();
        },
      );
    }
  }

  ///
  /// @name _hideLoading
  /// @description 隐藏加载圈
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-31
  ///
  _hideLoading() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    if (SingletonManager.sharedInstance!.isGuanKong!) {
      flutterWebviewPlugin!.close();
      flutterWebviewPlugin!.dispose();
      flutterWebviewPlugin = null;
    }
    super.dispose();
  }
}

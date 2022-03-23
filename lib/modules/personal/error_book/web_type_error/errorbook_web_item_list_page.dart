import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/locale/localizations.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/ett_pdf_model.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/modules/widgets/alert/select_question_prompt.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/loading/loading_view.dart';
import '../../../widgets/pdf/pdf_page.dart';


///
/// @name ErrorbookWebItemListPage
/// @description 错题本web 类型错题本详情页(包括:1系统错题;2数校错题;3质检消错错题)
/// @author waitwalker
/// @date 2020-01-11
///
class ErrorbookWebItemListPage extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<JavascriptChannel>? javascriptChannels;
  final int? subjectId;
  final bool fromShuXiao;

  const ErrorbookWebItemListPage({
    Key? key,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.subjectId,
    this.fromShuXiao = false,
  }) : super(key: key);

  @override
  _ErrorbookWebItemListPageState createState() => _ErrorbookWebItemListPageState();
}

class _ErrorbookWebItemListPageState extends State<ErrorbookWebItemListPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  WebViewController? _webviewController;
  bool showMenu = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //setState(() {});
  }

  var score;

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'native',
        onMessageReceived: (JavascriptMessage message) {
          onJsMessage(message.message);
        });
  }

  @override
  Future dispose() async {
    super.dispose();
    _webviewController?.canGoBack()?.then((b) => _webviewController!.goBack());
  }


  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
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
      return WillPopScope(
        onWillPop: () async {
          _controller.future.then((controller) {controller.evaluateJavascript('document.body.remove()');});
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
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
                  _refreshNavigationBar(true);
                },
              ),
            ],
          ),
          body: Container(
            // padding: EdgeInsets.all(32.0),
            child: setWebView(),
          ),
        ),
      );
    });
  }

  setWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebView(
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        initialUrl: Uri.encodeFull(widget.initialUrl!),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webviewController = webViewController;
          _controller.complete(webViewController);
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        onPageStarted: (String url) {
          print('Page start loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
      );
    } else {
      return WebView(
        initialUrl: Uri.encodeFull(widget.initialUrl!),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webviewController = webViewController;
          _controller.complete(webViewController);
        },
        javascriptChannels: widget.javascriptChannels ??
            <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
        onPageStarted: (String url) {
          print('Page start loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
      );
    }

  }

  ///
  /// @name _refreshNavigationBar
  /// @description 刷新导航栏
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-02
  ///
  _refreshNavigationBar(bool isTapped) {
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
  }

  /// js 调用flutter
  Future onJsMessage(String s) async {
    var decode = jsonDecode(s);
    print("decode:$decode");
    if (decode['qidlists'] != null) {
      List qidlists = decode['qidlists'];
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

    } else if (decode['goto'] != null) {
      WebViewController ctl = await _controller.future;
      ctl.loadUrl(Uri.encodeFull(widget.initialUrl!));
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
          _refreshNavigationBar(true);
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
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/test_paper_list_model.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// @name CommonWebview
/// @description 通用Webview 组件
/// @author waitwalker
/// @date 2020-01-10
///
class UnitTestErrorBookWebview extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<JavascriptChannel>? javascriptChannels;
  final Widget? action;
  final DataSource? dataSource;

  const UnitTestErrorBookWebview({
    Key? key,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.action,
    this.dataSource
  }) : super(key: key);

  @override
  _UnitTestErrorBookWebviewState createState() => _UnitTestErrorBookWebviewState();
}

class _UnitTestErrorBookWebviewState extends State<UnitTestErrorBookWebview> with SingleTickerProviderStateMixin {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  var _index = 0;
  /// 只看未消错
  bool onlyCorrected = false;
  bool isFinishedLoading = false;

  // 消错和未消错数量
  String totalCount = "";
  String correctCount = "";

  // 显示查看未消错按钮
  bool showCorrectButton = false;

  Future<LottieComposition> loadAsset(String assetName) async {
    var assetData = await rootBundle.load(assetName);
    return await LottieComposition.fromByteData(assetData);
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'native', onMessageReceived: (JavascriptMessage message) {
      print("消息message:${message.message}");
      onJsMessage(message.message);
    });
  }

  /// js 调用flutter
  Future onJsMessage(String s) async {
    var decode = jsonDecode(s);
    print("decode:$decode");
    if (decode is Map) {
      int? all = decode["all"];
      int? correct = decode["correct"];
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
    } else if (decode is String) {
      Map<String, dynamic> map = json.decode(decode);

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
    }
  }

  @override
  void initState() {
    totalCount = "${widget.dataSource!.totalCnt}";
    correctCount = "${widget.dataSource!.totalCnt! - widget.dataSource!.surplusCnt!}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = "共计错题: $totalCount  已经消错: $correctCount";
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
        backgroundColor: Color(MyColors.background),
        appBar: AppBar(
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
                _refreshNavigationBar(true);
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Container(
          // padding: EdgeInsets.all(32.0),
            child: IndexedStack(index: _index, children: <Widget>[
              Center(child: CircularProgressIndicator()),
              setWebView(),
            ])),
      ),
    );
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
          print('Page finished loading: $url');
          setState(() {
            _index = 1;
          });
        },
        onPageStarted: (String url){
          print('Page start loading: $url');
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
          print('Page finished loading: $url');
          setState(() {
            _index = 1;
          });
        },
        onPageStarted: (String url){
          print('Page start loading: $url');
        },
      );
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// @name CommonWebview
/// @description 通用Webview 组件
/// @author waitwalker
/// @date 2020-01-10
///
class UnitTestWebview extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<JavascriptChannel>? javascriptChannels;
  final Widget? action;

  const UnitTestWebview({
    Key? key,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.action,
  }) : super(key: key);

  @override
  _UnitTestWebviewState createState() => _UnitTestWebviewState();
}

class _UnitTestWebviewState extends State<UnitTestWebview> with SingleTickerProviderStateMixin {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  var _index = 0;
  // 是否加载结束
  bool isFinishedLoading = false;
  // 是否显示提交按钮
  bool showSubmitButton = false;

  Future<LottieComposition> loadAsset(String assetName) async {
    var assetData = await rootBundle.load(assetName);
    return await LottieComposition.fromByteData(assetData);
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'native', onMessageReceived: (JavascriptMessage message) {
      print("消息message:${message.message}");
      var decode = jsonDecode(message.message);
      print("decode:$decode");
      if (decode is Map) {
        String? btn = decode["btn"];
        if (btn == "open") {
          setState(() {
            showSubmitButton = true;
          });
        } else if (btn == "close") {
          setState(() {
            showSubmitButton = false;
          });
        }
      } else if (decode is String) {
        Map<String, dynamic> map = json.decode(decode);
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
      }

    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.title ?? '';
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
        appBar: AppBar(
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
          title: Text(title, style: TextStyle(fontSize: title.length > 11 ? 16 : 22),),
          backgroundColor: Colors.white,
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

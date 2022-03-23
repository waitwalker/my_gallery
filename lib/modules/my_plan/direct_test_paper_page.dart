import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

///
/// @name PDFPage
/// @description 直属试卷
/// @author waitwalker
/// @date 2020-01-10
///
class DirectTestPaperWebview extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<JavascriptChannel>? javascriptChannels;
  final Widget? action;
  final officeUrl;
  final Tasks? task;

  const DirectTestPaperWebview({
    Key? key,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.action,
    this.officeUrl,
    this.task,
  }) : super(key: key);
  _DirectTestPaperWebviewState createState() => _DirectTestPaperWebviewState();
}

class _DirectTestPaperWebviewState extends State<DirectTestPaperWebview> {
  String? path;
  Uri get uri => Uri.parse(Uri.encodeFull(widget.initialUrl!));
  String get scheme => uri.scheme;
  bool get isUrl => scheme == 'http' || scheme == 'https';
  bool get isFile => scheme == '';
  bool get loaded => path != null && File(path!).existsSync();
  bool isLoading = true;
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  var _index = 0;

  //var content_prefix = 'content://com.etiantian.online.wangxiao.flutter_downloader.provider/external/pdf';
  String get name => getName(Uri.encodeFull(widget.initialUrl!));

  Future<LottieComposition> loadAsset(String assetName) async {
    var assetData = await rootBundle.load(assetName);
    return await LottieComposition.fromByteData(assetData);
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'native', onMessageReceived: (JavascriptMessage message) {
      print("消息message:${message.message}");
      bool type = message.message is String;
      Map? map;
      print("type:$type");
      if (message.message is String) {
        map = json.decode(message.message);
        print("map:$map");
        if (map != null) {
        }
      } else if (message.message is Map) {

      }

    });
  }

  @override
  initState() {
    super.initState();
    if (isUrl)
      downloadFile(Uri.encodeFull(widget.initialUrl!));
    else if (isFile) {
      path = Uri.decodeComponent(uri.toString());
    }
    debugLog('---');
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
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = Platform.isAndroid
        ? await (getExternalStorageDirectory() as FutureOr<Directory>)
        : await getApplicationDocumentsDirectory();

    var pdfDir = Directory(directory.path + '/pdf');
    if (!pdfDir.existsSync()) {
      pdfDir.createSync();
    }
    return pdfDir.path;
  }

  Future<File> get _localFile async {
    final dir = await _localPath;
    return File('$dir/$name');
  }

  Future<File> writeCounter(Uint8List stream) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsBytes(stream);
  }

  Future<Uint8List> fetchPost(String url) async {
    final response = await http.get(Uri.parse(url));
    final responseJson = response.bodyBytes;

    return responseJson;
  }

  downloadFile(String url) async {
    writeCounter(await fetchPost(url));
    path = (await _localFile).path;

    if (!mounted) return;

    setState(() {});
  }

  getName(String url) {
    print("${url.split('/').last}");

    List strList = url.split("/");
    if (strList.length > 3) {
      return "直属试卷+" + strList[strList.length - 2] + "+" + strList.last;
    } else {
      return strList.last;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? title;
    if (widget.title != null) {
      title = widget.title!.replaceAll(".pdf", "");
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(title ?? ''),
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
                            if (isUrl) ...[
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
                                  onTap: () {
                                    Fluttertoast.showToast(msg: '已下载，可以在我的下载查看');
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
                                  debugLog('$path');
                                  debugLog('${File(path!).existsSync()}');
                                  if (Platform.isAndroid) {
                                    final result = await OpenFile.open(path);
                                    print("文件打开结果:$result");
                                  } else {

                                    final result = await OpenFile.open(path);
                                    print("文件打开结果:$result");
                                    //launch(uri.toString(), forceSafariVC: true);
                                  }
                                  Navigator.of(context).pop();
//                                  ShareExtend.share(path, "file");

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
                                  File file = await _localFile;
                                  if (!await file.exists()) {
                                    await file.create(recursive: true);
                                    file.writeAsStringSync("test for share documents file");
                                  }
                                  ShareExtend.share(file.path, "file");
                                }),
                            const SizedBox(width: 17),
                          ]),

                    ),
                  ).then((_) {
                    debugLog('####');
                  });
                })
          ]),
      body: Container(
          child: IndexedStack(index: _index, children: <Widget>[
            Center(child: CircularProgressIndicator()),
            setWebView(),
          ])),
    );
  }

  setWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebView(
        initialUrl: widget.officeUrl,
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
        initialUrl: widget.officeUrl,
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


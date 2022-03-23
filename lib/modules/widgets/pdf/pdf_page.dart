import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/date/doc_timer.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:my_gallery/modules/my_plan/my_plan_model.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:share_extend/share_extend.dart';

///
/// @name PDFPage
/// @description PDF页面
/// @author waitwalker
/// @date 2020-01-10
///
// ignore: must_be_immutable
class PDFPage extends StatefulWidget {
  String? _uri;
  String? title;
  String? resId;
  Tasks? task;
  String? officeURL;
  // 来自知识导学
  bool fromZSDX = false;

  PDFPage(this._uri, {Key? key, this.title, this.fromZSDX = false, this.resId, this.task, this.officeURL})
      : assert(!(fromZSDX && resId == null)),
        super(key: key);

  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  String? path;
  Uri get uri => Uri.parse(widget._uri!);
  String get scheme => uri.scheme;
  bool get isUrl => scheme == 'http' || scheme == 'https';
  bool get isFile => scheme == '';
  bool get loaded => path != null && File(path!).existsSync();
  bool isLoading = true;

  String get name => getName(widget._uri);
  FlutterWebviewPlugin? flutterWebviewPlugin;
  bool hasError = false;
  int type = 0;

  @override
  initState() {
    super.initState();
    if (isUrl)
      loadPdf(widget._uri!);
    else if (isFile) {
      path = Uri.decodeComponent(uri.toString());
    }
    if (widget.officeURL != null && widget.officeURL!.length> 0) {
      SharedPrefsUtils.put(name, widget.officeURL);
      SharedPrefsUtils.put(name + "ett", widget._uri);
    }
    debugLog('---');
    if (widget.fromZSDX) {
      DocTimer.startReportTimer(context, resId: widget.resId);
    }

    if (SingletonManager.sharedInstance!.isGuanKong!) {
      flutterWebviewPlugin = FlutterWebviewPlugin();
      flutterWebviewPlugin!.onDestroy.listen((_) {
        flutterWebviewPlugin!.dispose();
      } as void Function(Null)?);

      /// 监听加载状态
      flutterWebviewPlugin!.onStateChanged.listen((viewState) async {
        if (viewState.type == WebViewState.shouldStart) {
          print("应该加载");
        } else if (viewState.type == WebViewState.startLoad) {
          print("开始加载");
        } else if (viewState.type == WebViewState.finishLoad) {
          print("网页加载完成");
        }
      });

      /// 监听加载错误
      flutterWebviewPlugin!.onHttpError.listen((event) {
        Fluttertoast.showToast(msg: "网页加载遇到错误,请重试!");
        setState(() {
          hasError = true;
        });
      });
    }
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
    if (widget.fromZSDX) {
      DocTimer.stopTimer();
    }

    if (SingletonManager.sharedInstance!.isGuanKong!) {
      flutterWebviewPlugin!.close();
      flutterWebviewPlugin!.dispose();
      flutterWebviewPlugin = null;
    }
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

  loadPdf(String url) async {
    writeCounter(await fetchPost(url));
    path = (await _localFile).path;

    if (!mounted) return;

    setState(() {});
  }

  getName(String? url) {
    // check url format
    if (widget.title == null || widget.title!.length == 0) {
      var d = url!.lastIndexOf("/");

      if (d != -1) {
        print("${url.split('/').last}");
        return url.split('/').last;
      }
      return 'unknown.pdf';
    } else {
      print('${widget.title}.pdf');
      return '${widget.title}.pdf';
    }
  }

  @override
  Widget build(BuildContext context) {

    if (SingletonManager.sharedInstance!.isGuanKong!) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
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
                          File file = File(path!);
                          bool isExist = await file.exists();
                          if (isExist) {
                            if (Platform.isAndroid) {
                              final result = await OpenFile.open(path);
                              print("文件打开结果:$result");
                            } else {
                              final result = await OpenFile.open(path);
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
                          File file = await _localFile;
                          if (!await file.exists()) {
                            await file.create(recursive: true);
                            file.writeAsStringSync("test for share documents file");
                          }
                          ShareExtend.share(file.path, "file");
                        }),
                    const SizedBox(width: 17),
                  ]),
            ]
        ),
        body: Center(child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('static/images/pdf_cover.png', width: 204, height: 109, fit: BoxFit.fill),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text("请选择其他方式打开"),
            ],
          ),
          onTap: () async{
            debugLog('$path');
            debugLog('${File(path!).existsSync()}');
            if (Platform.isAndroid) {
              final result = await OpenFile.open(path);
              print("文件打开结果:$result");

              if (result.type != ResultType.done) {
                Fluttertoast.showToast(msg: "报告生成失败,重新生成一遍吧~");
              }

            } else {
              final result = await OpenFile.open(path);
              print("文件打开结果:$result");
              //launch(uri.toString(), forceSafariVC: true);
            }
          },
        ),),
      );
    } else {
      String? title;
      if (widget.title != null) {
        title = widget.title!.replaceAll(".pdf", "");
      }
      return Scaffold(
        appBar: AppBar(
            title: Text(title ?? '',style: TextStyle(fontSize: 14),),
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
        body: Container(child: loaded ? PdfView(path: path) : Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )),
      );
    }
  }
}

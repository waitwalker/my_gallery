import 'dart:async';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/date/time_utils.dart';
import 'package:my_gallery/model/ai_score_model.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

/// AI测试web页
class AIWebPage extends StatefulWidget {
  final String? initialUrl;
  final String? title;
  final Set<MTTJavascriptChannel>? javascriptChannels;
  final String? currentDirId;
  final String? subjectId;
  final String? versionId;
  final bool showTimeCount;

  AIWebPage({
    Key? key,
    this.currentDirId,
    this.subjectId,
    this.versionId,
    this.initialUrl,
    this.title,
    this.javascriptChannels,
    this.showTimeCount = true,
  }) : super(key: key);

  @override
  _AIWebPageState createState() => _AIWebPageState();
}

class _AIWebPageState extends State<AIWebPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  AnimationController? _lottieController;

  var _index = 1;

  Timer? _timer;
  static const int COUNT_DOWN = 10 * 60;
  int remain = COUNT_DOWN;

  late FlutterWebviewPlugin flutterWebviewPlugin;

  @override
  void initState() {
    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    loadAsset('assets/riding.json').then((composition) {
      _composition = composition;
      _lottieController!.repeat(period: Duration(seconds: 2));
      setState(() {});
    });
    WidgetsBinding.instance!.addObserver(this);
    flutterWebviewPlugin = FlutterWebviewPlugin();
    // HACK of issue: https://github.com/fluttercommunity/flutter_webview_plugin/issues/162
    flutterWebviewPlugin.onDestroy.listen((_) {
      flutterWebviewPlugin.dispose();
    } as void Function(Null)?);
    // _startTimer();
    flutterWebviewPlugin.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        setState(() {
          _index = 1;
          if (widget.showTimeCount) {
            _startTimer();
          }
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _safeCancelTimer();
    } else {
      _startTimer();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<LottieComposition> loadAsset(String assetName) async {
    var assetData = await rootBundle.load(assetName);
    return await LottieComposition.fromByteData(assetData);
  }

  var score;

  @override
  Future dispose() async {
    super.dispose();
    _safeCancelTimer();
    flutterWebviewPlugin.close();
    flutterWebviewPlugin.dispose();
  }

  void _safeCancelTimer() {
    _timer?.cancel();
  }

  void _startTimer() {
    if (remain < 1) {
      return;
    }
    if (_timer?.isActive ?? false) {
      return;
    }
    var lastRemain = remain;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      remain = lastRemain - timer.tick;
      if (remain <= 0) {
        _safeCancelTimer();
        _onCountdownOver();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: Platform.isIOS ? true : false,
        actions: <Widget>[
          widget.showTimeCount ?
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              child: Text(secToHMS(remain < 0 ? 0 : remain), style: textStyle25Primary)) :
          Container(),
        ],
      ),
      body: Container(
        // padding: EdgeInsets.all(32.0),
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Lottie(
                      composition: _composition,
                      controller: _lottieController,
                      width: 200,
                      height: 200,),
                    const SizedBox(height: 20),
                    Text('10分钟内，你能答对多少？\n出发吧！刷题鸭！',
                        style: textStyleContentMid333,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 200),
                  ]),
            ),
            Column(
              children: <Widget>[
                SizedBox(height: 1),
                Expanded(child: _setWebView(),)
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// @description 初始化Webview
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 4/15/21 9:34 AM
  ///
  _setWebView() {
    if (SingletonManager.sharedInstance!.isPadDevice &&
        SingletonManager.sharedInstance!.deviceType == "iPad") {
      return WebviewScaffold(
        userAgent: "Mozilla/5.0 (iPad; CPU OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
        scrollBar: false,
        url: Uri.encodeFull(widget.initialUrl!),
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
        withJavascript: true,
        clearCookies: true,
        clearCache: true,
        withLocalStorage: true,
        resizeToAvoidBottomInset: true,
      );
    }
  }

  ///
  /// @description 倒计时结束执行的操作
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 4/15/21 9:35 AM
  ///
  Future _onCountdownOver() async {
    ResponseData aiScore = await CourseDaoManager.aiScore(
        currentDirId: widget.currentDirId,
        subjectId: widget.subjectId,
        versionId: widget.versionId);
    if (aiScore.result) {
      AiScoreModel model = aiScore.model as AiScoreModel;

      flutterWebviewPlugin.hide();
      if (model.data != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('提示'),
            content:
            Text('时间到啦，您当前得分是${model.data!.completeData!.courseScore}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('确定'),
              ),
            ],
          ),
        ).then((_) {
          Navigator.of(context).pop(true);
        });
      }
    }
  }
}
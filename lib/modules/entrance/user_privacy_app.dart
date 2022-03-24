import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/locale/localizations_delegate.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/middleware.dart';
import 'package:my_gallery/common/theme/theme_manager.dart';
import 'package:my_gallery/model/app_info.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:redux/redux.dart';
import 'package:my_gallery/common/tools/umeng/umeng_tool.dart';
import 'dart:async';
import 'dart:io';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/tools/alert/alert.dart';
import 'package:my_gallery/common/tools/alert/alert_style.dart';
import 'package:my_gallery/common/tools/alert/dialog_button.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:flutter/services.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../main.dart';
import 'app.dart';


class UserPrivacyApp extends StatelessWidget {

  final store = Store<AppState>(appReducer,
      middleware: [loggingMiddleware],
      initialState: AppState(
          theme: ThemeManager.defaultTheme(),
          locale: Locale("zh","CH"),
          appInfo: AppInfo(),
          userInfo: UserInfoModel(),
          themeData: ThemeData(
            primarySwatch: MyColors.primarySwatch,
            primaryColor: Color(MyColors.primaryValue),
          )));

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StoreProvider(
      store: store,
      child: StoreBuilder<AppState>(builder: (context,store){
        return MaterialApp(
          title: RouteConst.app_name,
          home: HomePage(),//AdvertisementPage(),//LaunchAnimationPage(),
          ///多语言实现代理
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            MTTLocalizationsDelegate.delegate,
            ChineseCupertinoLocalizations.delegate, // 自定义的delegate
            DefaultCupertinoLocalizations.delegate, // 目前只包含英文
          ],
          locale: store.state.locale,
          supportedLocales: [store.state.locale!,Locale('zh', 'Hans'),],
          theme: store.state.themeData,
        );
      }),
    );
  }
}


///
/// @name LaunchAnimationPage
/// @description 启动动画页
/// @author waitwalker
/// @date 2020-01-10
///
class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  AnimationController? _controller;


  @override
  void initState() {
    super.initState();

    // 开启屏幕长亮
    Screen.keepOn(true);

    // 注释掉启动动画页的消息通道:这个通道用来处理跳转到网校App业务
    //methodChannel.setMethodCallHandler(_handler);
    /// 加载lottie 动画
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    loadAsset('assets/app.json').then((composition) {
      _composition = composition;
      setState(() {});
    }).then((_) {
      _controller!.forward();
    });

    /// 动画完成后进入主界面
    initLaunch();
  }

  ///
  /// @name initLaunch
  /// @description 进入主界面:区分是否有登录缓存数据
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2019-12-24
  ///
  Future initLaunch() async {
    Future.delayed(const Duration(milliseconds: 500), () {
      _userPrivacy();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  /// @Method: userPrivacy
  /// @Parameter:
  /// @ReturnType:
  /// @Description: 用户隐私弹框逻辑
  /// @author: lca
  /// @Date: 2019-08-05
  ///
  _userPrivacy() async{
    if (SingletonManager.sharedInstance!.isPadDevice) {
      _padUserPrivacyAlert();
    } else {
      _userPrivacyAlert();
    }
  }

  _userPrivacyAlert() {
    Alert(
      canPopScope: false,
      context: context,
      closeFunction: (){
        /// 这里退出应用
        exit(0);
      },
      title: "用户协议和隐私政策",
      style: AlertStyle(titleStyle: TextStyle(fontSize: 16),
        descStyle: TextStyle(fontSize: 14),
        isCloseButton: false,
        isOverlayTapDismiss: false,
        overlayColor: Color.fromRGBO(0, 0, 0, 0.6),
      ),
      content: MediaQuery.removePadding(removeTop: true, context: context, child: Container(
          color: Colors.transparent,
          height: 240,
          width: MediaQuery.of(context).size.width - 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ListView(
                children: [
                  Text(APIConst.UserPrivacy,
                    style: TextStyle(fontSize: 12),),
                ],
              )),
              Container(color: Colors.transparent, height: 5,),
              Row(
                children: [
                  Text("详细请点击查看:", style: TextStyle(fontSize: 14),),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 5)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/about/mobile/servandpriv.html', title: '用户协议');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《用户协议》", style: TextStyle(fontSize: 14, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                  Text("&", style: TextStyle(fontSize: 16),),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/privacy.html', title: '隐私政策');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《隐私政策》", style: TextStyle(fontSize: 14, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                ],
              ),
            ],
          )

      )),
      buttons: [
        DialogButton(
          child: Text(
            "退出",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: () {
            /// 这里退出应用
            exit(0);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "同意",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: () {
            saveUserPrivacy();
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  _padUserPrivacyAlert() {
    Alert(
      canPopScope: false,
      context: context,
      closeFunction: (){
        /// 这里退出应用
        exit(0);
      },
      title: "用户协议和隐私政策",
      style: AlertStyle(titleStyle: TextStyle(fontSize: 26),
        descStyle: TextStyle(fontSize: 24),
        isCloseButton: false,
        isOverlayTapDismiss: false,
        overlayColor: Color.fromRGBO(0, 0, 0, 0.6),
      ),
      content: MediaQuery.removePadding(removeTop: true, context: context, child: Container(
          color: Colors.transparent,
          height: 340,
          width: MediaQuery.of(context).size.width - 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ListView(
                children: [
                  Text(APIConst.UserPrivacy,
                    style: TextStyle(fontSize: 18),),
                ],
              )),
              Container(color: Colors.transparent, height: 5,),
              Row(
                children: [
                  Text("详细请点击查看:", style: TextStyle(fontSize: 14),),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 5)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/about/mobile/servandpriv.html', title: '用户协议');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《用户协议》", style: TextStyle(fontSize: 18, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                  Text("&", style: TextStyle(fontSize: 18),),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) {
                        return CommonWebviewPage(initialUrl: 'https://www.etiantian.com/privacy.html', title: '隐私政策');
                      }));
                    },
                    child: Container(
                      height: 28,
                      child: Text("《隐私政策》", style: TextStyle(fontSize: 18, color: Color.fromRGBO(0, 170, 125, 1.0),),),),
                  ),
                ],
              ),
            ],
          )

      )),
      buttons: [
        DialogButton(
          child: Text(
            "退出",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          onPressed: () {
            /// 这里退出应用
            exit(0);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "同意",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          onPressed: () {
            saveUserPrivacy();
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  /// 保存用户隐私
  saveUserPrivacy() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("userPrivacy", true);

    FlutterError.onError = (FlutterErrorDetails details) {
      reportErrorAndLog(details);
    };

    /// 初始化友盟统计
    await UmengTool.init();

    /// event 监听事件
    ErrorCode.eventBus.on<dynamic>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await plugin.iosInfo;
      SingletonManager.sharedInstance!.deviceName = iosDeviceInfo.name;
      SingletonManager.sharedInstance!.deviceType = iosDeviceInfo.model;
      SingletonManager.sharedInstance!.systemName = iosDeviceInfo.systemName;
      SingletonManager.sharedInstance!.systemVersion = iosDeviceInfo.systemVersion;
      if (iosDeviceInfo.model == "iPad") {
        SingletonManager.sharedInstance!.isPadDevice = true;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      } else {
        // debugPaintSizeEnabled = true;
        SingletonManager.sharedInstance!.isPadDevice = false;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      }

    } else if (Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo = await plugin.androidInfo;
      SingletonManager.sharedInstance!.deviceName = androidDeviceInfo.brand;
      SingletonManager.sharedInstance!.deviceType = androidDeviceInfo.model;
      SingletonManager.sharedInstance!.systemName = "Android";
      SingletonManager.sharedInstance!.systemVersion = androidDeviceInfo.version.release;
      MethodChannel channel = MethodChannel("com.etiantian/device_type");
      var result = await channel.invokeMethod("deviceType") ?? false;
      print("device is pad:$result");
      bool isTab = result["isTab"];
      bool? isGuanKong = result["isGuanKong"];
      SingletonManager.sharedInstance!.isGuanKong = isGuanKong;
      if (isTab) {
        SingletonManager.sharedInstance!.isPadDevice = true;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      } else {
        SingletonManager.sharedInstance!.isPadDevice = false;
        runZonedGuarded(() => runApp(App()), (Object obj, StackTrace stack){
          var details = makeDetails(obj, stack);
          reportErrorAndLog(details);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(height: 640, width: 360)..init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);


    return StoreBuilder(builder: (BuildContext context, Store<AppState> store){
      return _buildPage(context);
    });
  }




  Widget _buildPage(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (w / h < 9 / 16.0) {
      h = (16 / 9) * w;
    }
    return Container(
      // alignment: Alignment.center,
      // width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: w,
              height: h,
              // color: Colors.red,
              child: Lottie(
                composition: _composition,
                height: h,
                width: w,
                controller: _controller,
              ),
            ),
            Positioned(
              bottom: 58,
              child: Image.asset(
                  'static/images/img_launch_logo.png',
                  width: 183,
                  height: 43),
            )
          ],
        ));
  }
}

Future<LottieComposition> loadAsset(String assetName) async {
  var assetData = await rootBundle.load(assetName);
  return await LottieComposition.fromByteData(assetData);
}
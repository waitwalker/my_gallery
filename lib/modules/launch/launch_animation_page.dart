import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/dao/manager/dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/locale/locale_manager.dart';
import 'package:my_gallery/common/dao/original_dao/user_info_dao.dart';
import 'package:my_gallery/common/network/response.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/common/theme/theme_manager.dart';
import 'package:my_gallery/common/tools/alert/alert.dart';
import 'package:my_gallery/common/tools/alert/alert_style.dart';
import 'package:my_gallery/common/tools/alert/dialog_button.dart';
import 'package:my_gallery/model/login_model.dart';
import 'package:my_gallery/model/my_course_model.dart';
import 'package:my_gallery/model/user_info_model.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/user_reducer.dart';
import 'package:my_gallery/common/tools/screen_adapt/screen_utils.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_gallery/modules/entrance/tabbar_container_page.dart';
import 'package:my_gallery/modules/login/login_page.dart';
import 'package:my_gallery/modules/my_plan/my_plan_authority_model.dart';
import 'package:my_gallery/modules/personal/error_book/unit_test/unit_test_authority_model.dart';
import 'package:my_gallery/modules/widgets/webviews/common_webview_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

///
/// @name LaunchAnimationPage
/// @description 启动动画页
/// @author waitwalker
/// @date 2020-01-10
///
class LaunchAnimationPage extends StatefulWidget {
  @override
  _LaunchAnimationState createState() => new _LaunchAnimationState();
}

class _LaunchAnimationState extends State<LaunchAnimationPage>
    with SingleTickerProviderStateMixin {
  var isLogin = false;
  var isBind = false;
  LottieComposition? _composition;
  AnimationController? _controller;
  int? localeIndex = 0;
  int? themeIndex = 0;
  bool showAlert = false;
  bool isLogin_ = false;
  bool isExpire_ = false;
  bool isBind_ = false;

  /// 安卓跳转是否冷启动
  //bool isJumpColdStarted = false;

  MethodChannel methodChannel = const MethodChannel("aixue_wangxiao_channel");



  @override
  void initState() {
    super.initState();

    // 开启屏幕长亮
    Screen.keepOn(true);

    // 注释掉启动动画页的消息通道:这个通道用来处理跳转到网校App业务
    //methodChannel.setMethodCallHandler(_handler);
    /// 加载lottie 动画
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 2000),
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

  /// 读取本地缓存数据
  readLocalCacheData() async {
    Store<AppState> store = StoreProvider.of(context);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    /// 获取主题
    themeIndex = sharedPreferences.getInt("theme");
    if (themeIndex == null) {
      themeIndex = 0;
    }
    ThemeManager.pushTheme(store, themeIndex!);

    /// 获取语言
    localeIndex = sharedPreferences.getInt("locale");

    if (localeIndex == null) {
      localeIndex = 0;
    }
    LocaleManager.changeLocale(store, localeIndex!);
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
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? isAgreed = sharedPreferences.getBool("userPrivacy");
    if (isAgreed == null || isAgreed == false) {
      SingletonManager.sharedInstance!.isFirstInstallApp = true;
      showAlert = true;
    } else {
      SingletonManager.sharedInstance!.isFirstInstallApp = false;
      showAlert = false;
    }
    var loginJson = SharedPrefsUtils.getString(APIConst.LOGIN_JSON);
    var ccLoginModel;
    if (loginJson == null || loginJson.isEmpty) {
      isLogin = false;
    } else {
      try {
        ccLoginModel = LoginModel.fromJson(jsonDecode(loginJson));
      } on Exception catch (_) {
        isLogin = false;
      }
    }
    isLogin = ccLoginModel != null;
    var isExpire = false;
    if (isLogin) {
      isExpire = DateTime.now().millisecondsSinceEpoch >=
          (ccLoginModel.expiration ?? 0);
      if (isExpire) {
        // noop
      } else {
        var info = await UserInfoDao.getUserInfo();
        if (info.result && info.model != null && info.model.code == 1) {
          UserInfoModel model = info.model as UserInfoModel;
          SingletonManager.sharedInstance!.shouldDegrade = model.data!.ZLDeclineStatus == 1;
          SingletonManager.sharedInstance!.userName = model.data!.userName;
          isBind = model.data!.bindingStatus == 1;
          _getStore().dispatch(UpdateUserAction(model));
        }
      }
    }

    if (showAlert == true) {
      _userPrivacy();
      return;
    }

    isLogin_ = isLogin;
    isExpire_ = isExpire;
    isBind_ = isBind;

    Future.delayed(const Duration(milliseconds: 3000), () {
      /// 首页弹框置为默认值
      SingletonManager.sharedInstance!.isHaveLoadedAlert = false;
      /// 如果是冷启动跳转
      if (SingletonManager.sharedInstance!.isJumpColdStart) {
        //isJumpColdStarted = false;
        SingletonManager.sharedInstance!.isHaveLogin = false;
        SingletonManager.sharedInstance!.isJumpColdStart = true;
        //NavigatorRoute.login(context);
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
      } else {
        if (isLogin && !isExpire && isBind) {
          /// 获取用户质检消错权限
          _fetchUnitTestAuthority();
          SingletonManager.sharedInstance!.isHaveLogin = true;
          _fetchPlanAuthority();
        } else {
          SingletonManager.sharedInstance!.isHaveLogin = false;
          //NavigatorRoute.login(context);
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  /// @description 获取质检消错权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/10/28 3:21 PM
  ///
  void _fetchUnitTestAuthority() async {
    ResponseData responseData = await DaoManager.fetchUnitTestAuthority({});
    if (responseData.code == 200) {
      UnitTestAuthorityModel model = responseData.model;
      SingletonManager.sharedInstance!.authorityModel = model;
      if (model.code! > 0 && model.data != null) {
        SingletonManager.sharedInstance!.unitTestAuthority = true;
      } else {
        SingletonManager.sharedInstance!.unitTestAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.unitTestAuthority = false;
    }
    print("response:$responseData");
  }

  ///
  /// @description 获取智领权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2021/8/5 10:27
  ///
  _zhiLingAuth() async {
    ResponseData responseData = await CourseDaoManager.newCourses();
    if (responseData.result && responseData.model != null) {
      MyCourseModel? courseModel = responseData.model as MyCourseModel?;
      if (courseModel != null) {
        if (courseModel.data != null && courseModel.data!.length > 0) {
          courseModel.data!.forEach((element) {
            if (element.grades != null && element.grades!.length > 0) {
              SingletonManager.sharedInstance!.zhiLingAuthority = true;
              print("用户有智领权限");
            }
          });
        } else {
          SingletonManager.sharedInstance!.zhiLingAuthority = false;
        }
      } else {
        SingletonManager.sharedInstance!.zhiLingAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.zhiLingAuthority = false;
    }
  }

  ///
  /// @description 获取计划权限
  /// @param
  /// @return
  /// @author waitwalker
  /// @time 2020/12/03 3:21 PM
  ///
  void _fetchPlanAuthority() async {
    _zhiLingAuth();
    ResponseData responseData = await DaoManager.fetchMyPlanAuthority({});
    if (responseData.code == 200) {
      MyPlanAuthorityModel model = responseData.model;
      if (model.code! > 0 && model.data != null) {
        if (model.data == 1) {
          SingletonManager.sharedInstance!.planAuthority = true;
        } else {
          SingletonManager.sharedInstance!.planAuthority = false;
        }
      } else {
        SingletonManager.sharedInstance!.planAuthority = false;
      }
    } else {
      SingletonManager.sharedInstance!.planAuthority = false;
    }
    //NavigatorRoute.goToTabBarPage(context);
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: TabBarHomePage()));
    print("response:$responseData");
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
            //startCountDown();
            Navigator.pop(context);

            /// 首页弹框置为默认值
            SingletonManager.sharedInstance!.isHaveLoadedAlert = false;
            /// 如果是冷启动跳转
            if (SingletonManager.sharedInstance!.isJumpColdStart) {
              //isJumpColdStarted = false;
              SingletonManager.sharedInstance!.isHaveLogin = false;
              SingletonManager.sharedInstance!.isJumpColdStart = true;
              //NavigatorRoute.login(context);
              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
            } else {
              if (isLogin_ && !isExpire_ && isBind_) {
                SingletonManager.sharedInstance!.isHaveLogin = true;
                //NavigatorRoute.goToTabBarPage(context);
                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: TabBarHomePage()));
              } else {

                /// 用户隐私权限这里点击确定肯定会走到这里,因为首次没有登录过
                SingletonManager.sharedInstance!.isHaveLogin = false;
                //NavigatorRoute.login(context);
                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
              }
            }
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
            //startCountDown();
            Navigator.pop(context);

            /// 首页弹框置为默认值
            SingletonManager.sharedInstance!.isHaveLoadedAlert = false;
            /// 如果是冷启动跳转
            if (SingletonManager.sharedInstance!.isJumpColdStart) {
              //isJumpColdStarted = false;
              SingletonManager.sharedInstance!.isHaveLogin = false;
              SingletonManager.sharedInstance!.isJumpColdStart = true;
              //NavigatorRoute.login(context);
              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
            } else {
              if (isLogin_ && !isExpire_ && isBind_) {
                SingletonManager.sharedInstance!.isHaveLogin = true;
                //NavigatorRoute.goToTabBarPage(context);
                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
              } else {

                /// 用户隐私权限这里点击确定肯定会走到这里,因为首次没有登录过
                SingletonManager.sharedInstance!.isHaveLogin = false;
                //NavigatorRoute.login(context);
                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginPage()));
              }
            }
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
  }


  @override
  void didChangeDependencies() {
    readLocalCacheData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(height: 640, width: 360)..init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return _buildPage(context, store);
    });
  }

  Store<AppState> _getStore() {
    return StoreProvider.of<AppState>(context);
  }

  Widget _buildPage(BuildContext context, Store<AppState> store) {
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
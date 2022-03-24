import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:my_gallery/common/config/config.dart';
import 'package:my_gallery/common/const/api_const.dart';
import 'package:my_gallery/common/const/router_const.dart';
import 'package:my_gallery/common/dao/original_dao/login_dao.dart';
import 'package:my_gallery/common/network/error_code.dart';
import 'package:my_gallery/common/dao/original_dao/course_dao_manager.dart';
import 'package:my_gallery/common/dao/original_dao/common_api.dart';
import 'package:my_gallery/common/singleton/singleton_manager.dart';
import 'package:my_gallery/event/card_activate_event.dart';
import 'package:my_gallery/event/http_error_event.dart';
import 'package:my_gallery/model/check_update_model.dart';
import 'package:my_gallery/model/unread_count_model.dart';
import 'package:my_gallery/common/redux/app_state.dart';
import 'package:my_gallery/common/redux/unread_msg_count_reducer.dart';
import 'package:my_gallery/modules/my_plan/plan_page.dart';
import 'package:my_gallery/modules/personal/personal_page.dart';
import 'package:my_gallery/modules/widgets/style/style.dart';
import 'package:my_gallery/common/tools/date/eye_protection_timer.dart';
import 'package:my_gallery/common/tools/date/report_timer.dart';
import 'package:my_gallery/common/tools/share_preference/share_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:screen/screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
import '../personal/message/message_detail_page.dart';
import '../my_course/my_course.dart';

///
/// @name TabBarHomePage
/// @description TabBar 容器页面 包含:1)我的课程;2)我的
/// @author waitwalker
/// @date 2020-01-10
///
class TabBarHomePage extends StatefulWidget {
  _TabBarHomePageState createState() => _TabBarHomePageState();
}

class _TabBarHomePageState extends State<TabBarHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController controller;
  bool isSearch = false;
  String data2ThirdPage = '这是传给ThirdPage的值';
  String? appBarTitle = tabData[0]['text'];
  static List tabData = SingletonManager.sharedInstance!.planAuthority ?
  [
    {'text': '我的课程', 'icon': Icon(MyIcons.COURSE_TAB)},
    {'text': '我的计划', 'icon': Icon(MyIcons.COURSE_TAB)},
    {'text': '个人中心', 'icon': Icon(MyIcons.MINE_TAB)}
  ] :
  [
    {'text': '我的课程', 'icon': Icon(MyIcons.COURSE_TAB)},
    {'text': '个人中心', 'icon': Icon(MyIcons.MINE_TAB)}
  ];

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  List<Widget> myTabs = [];
  int last = 0;
  GlobalKey _tabNewKey = GlobalKey();

  MethodChannel methodChannel = const MethodChannel("aixue_wangxiao_channel");

  ///
  /// @MethodName 跳转处理状态3
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2020-02-03
  ///
  Future<dynamic>? _handler(MethodCall methodCall) {
    print("${methodCall.method}");
    if (SingletonManager.sharedInstance!.isHaveLogin == true) {
      SingletonManager.sharedInstance!.shouldShowActivityCourse = false;
      /// 这里是否需要跳转到登录页处理一下  还是直接刷新token
      print("首页处理跳转");
      if (methodCall.arguments != null) {
        List<String> arguments = methodCall.arguments.toString().split("&");
        String account = arguments[0];
        String password = arguments[1];
        String isVip = arguments[2];
        String gradeId = arguments[3];
        if (account != null && password != null) {
          SingletonManager.sharedInstance!.aixueAccount = account;
          SingletonManager.sharedInstance!.aixuePassword = password;
          SingletonManager.sharedInstance!.isVip = isVip;
          SingletonManager.sharedInstance!.gradeId = gradeId;
        }
      }

      Navigator.pushNamedAndRemoveUntil(
          context, RouteConst.login, (Route<dynamic> route) => false);
    }
    return null;
  }

  Future<bool> doubleClickBack() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('提示'),
            content: Text('确定要退出App吗？'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('确定'),
              ),
            ],
          ),
        ).then((value) => value as bool) ??
        false as Future<bool>;
  }

  final PageController _controller = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    double itemFontSize = SingletonManager.sharedInstance!.isPadDevice ?  16 : 11;
    double itemIconSize = SingletonManager.sharedInstance!.isPadDevice ?  40 : 30;
    return StoreBuilder(builder: (BuildContext context, Store<AppState> store) {
      return Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,
          children: <Widget>[
            /// 我的课程页面
            MyCoursePage(key: _tabNewKey),

            // 全时自习室
            if (SingletonManager.sharedInstance!.planAuthority)
              MyPlanPage(),

            /// 我的页面
            PersonalPage(),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          unselectedLabelStyle: TextStyle(fontSize: itemFontSize, color: Color(0xffB0BACB)),
          selectedLabelStyle: TextStyle(fontSize: itemFontSize, color: Color(0xff2E96FF)),
          unselectedItemColor: Color(0xffB0BACB),
          selectedItemColor: Color(0xff2E96FF),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index){
            setState(() {
              _controller.jumpToPage(index);
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('static/images/tabbar_item_my_course_normal.png', width: itemIconSize, height: itemIconSize,),
              activeIcon: Image.asset('static/images/tabbar_item_my_course_selected.png', width: itemIconSize, height: itemIconSize,),
              label: "我的课程",
            ),
            if (SingletonManager.sharedInstance!.planAuthority)
              BottomNavigationBarItem(
                icon: Image.asset('static/images/tabbar_item_plan_normal.png', width: itemIconSize, height: itemIconSize,),
                activeIcon: Image.asset('static/images/tabbar_item_plan_selected.png', width: itemIconSize, height: itemIconSize,),
                label: "全时自习室",
              ),

            BottomNavigationBarItem(
                icon: Image.asset('static/images/tabbar_item_personal_center_normal.png', width: itemIconSize, height: itemIconSize,),
                activeIcon: Image.asset('static/images/tabbar_item_personal_center_selected.png', width: itemIconSize, height: itemIconSize,),
                label: "个人中心"
            ),
          ],
        ),
      );
    });
  }

  Store<AppState> _getStore() => StoreProvider.of<AppState>(context);

  @override
  void initState() {
    super.initState();

    // 开启屏幕长亮
    Wakelock.enable();

    Screen.keepOn(true);

    methodChannel.setMethodCallHandler(_handler as Future<dynamic> Function(MethodCall)?);
    WidgetsBinding.instance!.addObserver(this);
    EyeProtectionTimer.startEyeProtectionTimer(context);
    ReportTimer.startReportTimer(context);

    final JPush jpush = JPush();

    jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic>? message) async {
        print("flutter onReceiveNotification: $message");

        // 刷新未读消息数红点
        Future.delayed(Duration(seconds: 3), () {
          CourseDaoManager.unreadMsgCount().then((response) {
          if (response.result) {
            var model = response.model as UnreadCountModel?;
            _getStore().dispatch(UpdateMsgAction(model?.data as int? ?? 0));
          }
        });
        });
      },
      onOpenNotification: (Map<String, dynamic>? message) async {
        var msgId;
        if (Platform.isAndroid) {
          msgId =
              jsonDecode(message!['extras']['cn.jpush.android.EXTRA'])['msgId'];
        } else {
          msgId = message!['extras']['msgId'];
        }
        var id = (msgId is String) ? int.parse(msgId) : msgId;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => MessageDetailPage(msgId: id)));
        print("flutter onOpenNotification: $message $msgId");
      },
      onReceiveMessage: (Map<String, dynamic>? message) async {
        print("flutter onReceiveMessage: $message");
      },
    );

    ///
    /// @name eventBus
    /// @description event 监听事件
    /// @parameters []
    /// @return void
    /// @author waitwalker
    /// @date 2020-01-14
    ///
    ErrorCode.eventBus.on<dynamic>().listen((e) {
      if (mounted) {
        if (e is HttpErrorEvent && e.code == ErrorCode.EXPIRED) {
          Fluttertoast.showToast(msg: e.message);
          _logout();
          Navigator.pushNamedAndRemoveUntil(
              context, RouteConst.login, (Route<dynamic> route) => false);
        } else if (e is CardActivateEvent) {
          _currentIndex = 0;
          controller.animateTo(_currentIndex);
          _tabNewKey = GlobalKey();
        }
      }
    });

    controller = TabController(
        initialIndex: 0, vsync: this, length: SingletonManager.sharedInstance!.planAuthority ? 3 : 2); // 这里的length 决定有多少个底导 submenus
    for (int i = 0; i < tabData.length; i++) {
      myTabs.add(Tab(text: tabData[i]['text'], icon: tabData[i]['icon']));
    }
    controller.addListener(() {
      if (controller.indexIsChanging) {
        _onTabChange();
      }
    });
    // Application.controller = controller;
    checkUpdate();

    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print("result:$result");
      if (result == ConnectivityResult.none) {
        ErrorCode.errorHandleFunction(ErrorCode.NETWORK_ERROR, "网络已断开", false);
      }
    });
  }

  ///
  /// @description 收到401时,退出登录,清空部分缓存数据
  /// @param 
  /// @return 
  /// @author waitwalker
  /// @time 11/24/20 8:55 AM
  ///
  void _logout() {
    ReportTimer.stopTimer();
    LoginDao.logout();

    EyeProtectionTimer.stopTimer();
    SharedPrefsUtils.remove(APIConst.LOGIN_JSON);
    JPush().deleteAlias();
    /// 首页弹框置为默认值
    SingletonManager.sharedInstance!.isHaveLoadedAlert = false;
    SingletonManager.sharedInstance!.isJumpFromAixue = false;
    SingletonManager.sharedInstance!.isJumpColdStart = false;
    SingletonManager.sharedInstance!.isHaveLogin = false;
    SingletonManager.sharedInstance!.shouldShowActivityCourse = true;
    SingletonManager.sharedInstance!.aixueAccount = "";
    SingletonManager.sharedInstance!.aixuePassword = "";
    SingletonManager.sharedInstance!.isVip = "";
    SingletonManager.sharedInstance!.gradeId = "";
  }

  //平台消息是异步的，所以我们用异步方法初始化。
  Future<Null> initConnectivity() async {
    String connectionStatus;
    //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // 如果在异步平台消息运行时从树中删除了该小部件，
    // 那么我们希望放弃回复，而不是调用setstate来更新我们不存在的外观。
    if (!mounted) {
      return;
    }

  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    var last_login = SharedPrefsUtils.getString('last_login');
    var this_login = StoreProvider.of<AppState>(context).state.userInfo!.data!.userName;
    SharedPrefsUtils.putString('last_login',
        StoreProvider.of<AppState>(context).state.userInfo!.data!.userName!);
    if (last_login != this_login) {
      SharedPrefsUtils.remove('record');
    }
  }

  @override
  void dispose() {
    // controller.dispose();
    _connectivitySubscription.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    EyeProtectionTimer.stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 护眼模式，应用退到后台，再回来，重新计时
    // 和直播页面不同的是，观看直播，暂停计时，退出直播，继续计时
    if (state == AppLifecycleState.paused) {
      EyeProtectionTimer.stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      EyeProtectionTimer.startEyeProtectionTimer(context);
    }
    setState(() {});
  }

  void _onTabChange() {
    if (this.mounted) {
      this.setState(() {
        appBarTitle = tabData[controller.index]['text'];
      });
    }
  }

  void _onTap(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
      setState(() {});
    }
  }

  Future checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var versionName = 'V${packageInfo.version}';
    SingletonManager.sharedInstance!.appCurrentVersionString = packageInfo.version;
    var checkUpdate = await CommonServiceDao.checkUpdate(version: versionName);
    if (checkUpdate.result && checkUpdate.model != null) {
      var model = checkUpdate.model as CheckUpdateModel;
      if (model.result == 1) {
        var data = model.data!;
        if (data.forceType == 1 || model.data!.forceType == 2) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                List<Widget> actions = <Widget>[
                  TextButton(
                    child: Text('确定'),
                    onPressed: () async {
                      if (Platform.isIOS) {
                        await launch(APIConst.appStoreURL);
                        if (data.forceType == 2) {
                        } else {
                          Navigator.of(context).pop();
                        }
                        return;
                      } else {
                        await launch(data.url!);
                        if (data.forceType == 2) {
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ];
                if (model.data!.forceType == 1) {
                  var cancel = TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text('取消'),
                  );
                  actions.add(cancel);
                }
                return WillPopScope(
                  onWillPop: () => Future.value(model.data!.forceType == 1),
                  child: AlertDialog(
                      title: Text(data.title!),
                      content: Text(data.message!),
                      actions: actions),
                );
              });
        }
      }
    }
  }
}



import 'package:my_gallery/modules/flu_app/config/printer.dart';

class FluRouterPageAPI {
  
  /// 首页
  static const String homePage = "/home";

  /// isolate 页面
  static const String isolatePage = "/home/isolate";

  /// platformView 页面
  static const String platformViewPage = "/home/platformView";

  /// notification 页面
  static const String notificationPage = "/home/notification";

  /// mixin 页面
  static const String mixinPage = "/home/mixin";

  /// animation 页面
  static const String animationPage = "/home/animation";

  /// hero 页面
  static const String heroPage = "/home/animation/hero";

  /// event penetration 页面
  static const String eventPenetrationPage = "/home/eventPenetration";

  /// ad 页面
  static const String adPage = "/home/ad";

  /// ke_frame 页面
  static const String keFramePage = "/home/keFrame";

  /// canvas 页面
  static const String canvasPage = "/home/canvas";

  /// paint1 页面
  static const String paint1Page = "/home/paint1";

  /// paint2 页面
  static const String paint2Page = "/home/paint2";

  /// paint3 页面
  static const String paint3Page = "/home/paint3";

  /// paint4 页面
  static const String paint4Page = "/home/paint4";

  /// paint5 页面
  static const String paint5Page = "/home/paint5";

  /// paint6 页面
  static const String paint6Page = "/home/paint6";

  /// paint7 页面
  static const String paint7Page = "/home/paint7";


  /// ad splash页面
  static const String adSplashPage = "/home/ad/splash";

  /// sliver entrance 页面
  static const String sliverEntrancePage = "/home/sliverEntrancePage";

  /// sliver list 页面
  static const String sliverListPage = "/home/sliverEntrancePage/list";

  /// sliver appbar 页面
  static const String sliverAppBarPage = "/home/sliverEntrancePage/appbar";

  /// sliver sticky 页面
  static const String sliverStickyPage = "/home/sliverEntrancePage/sticky";

  /// sliver custom header 页面
  static const String sliverCustomHeaderPage = "/home/sliverEntrancePage/customHeader";

  /// meituan shop 页面
  static const String meituanShopPage = "/home/sliverEntrancePage/meituanShopPage";

  /// tabBar 页面
  static const String tabBarPage = "/home/tabBarPage";

  /// order 页面
  static const String orderPage = "/home/orderPage";

  /// chart 页面
  static const String chartPage = "/home/chartPage";

  /// positionAnimationPage 页面
  static const String positionAnimationPage = "/home/positionAnimationPage";

  /// 底部导航容器页
  static const String bottomNavigationBarPage = "/bottom_navigation_bar";

  /// 启动页
  static const String splashPage = "/splash";

  /// 联系人列表页
  static const String contactPage = "/contact";

  /// 聊天页面
  static const String chatPage = "/contact/chat";

  /// 个人中心页面
  static const String personalPage = "/personal";

  /// 腾讯直播登录页面
  static const String tLoginPage = "/t_login";

  /// 直播索引页面
  static const String indexPage = "/t_index";

  /// 直播列表页面
  static const String liveListPage = "/liveRoom/list";

  /// 创建直播页面
  static const String createLivePage = "/liveRoom/roomCreate";

  /// 直播页面 推流
  static const String livePage = "/liveRoom/roomAnchor";

  /// 直播观看页面 拉流
  static const String audiencePage = "/liveRoom/roomAudience";

  FluRouterPageAPI._internal(){
    printer("FluRouterPageAPI单例初始化");
  }
  static FluRouterPageAPI? _sharedInstance;
  static FluRouterPageAPI? _getInstance() {
    _sharedInstance ??= FluRouterPageAPI._internal();
    return _sharedInstance;
  }

  factory FluRouterPageAPI() => _getInstance()!;

  static FluRouterPageAPI? get sharedInstance => _getInstance();

  
}
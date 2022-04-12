import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/ad/ad_page.dart';
import 'package:my_gallery/modules/flu_app/ad/ad_splash_page.dart';
import 'package:my_gallery/modules/flu_app/animation/animation_page.dart';
import 'package:my_gallery/modules/flu_app/animation/hero_page.dart';
import 'package:my_gallery/modules/flu_app/animation/position_animation.dart';
import 'package:my_gallery/modules/flu_app/canvas/canvas_entrance_page.dart';
import 'package:my_gallery/modules/flu_app/canvas/paint_3_page.dart';
import 'package:my_gallery/modules/flu_app/canvas/paint_4_page.dart';
import 'package:my_gallery/modules/flu_app/canvas/paint_5_page.dart';
import 'package:my_gallery/modules/flu_app/canvas/paint_6_page.dart';
import 'package:my_gallery/modules/flu_app/canvas/paint_7_page.dart';
import 'package:my_gallery/modules/flu_app/chart/chart_page.dart';
import 'package:my_gallery/modules/flu_app/common/place_holder_page.dart';
import 'package:my_gallery/modules/flu_app/entrance/flu_bottom_navigation_bar_page.dart';
import 'package:my_gallery/modules/flu_app/event_penetration/event_penetration_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_page.dart';
import 'package:my_gallery/modules/flu_app/isolate/isolate_page.dart';
import 'package:my_gallery/modules/flu_app/ke_frame_listview/KeFrameListViewPage.dart';
import 'package:my_gallery/modules/flu_app/message_module/chat_page.dart';
import 'package:my_gallery/modules/flu_app/message_module/contact_page.dart';
import 'package:my_gallery/modules/flu_app/mixin_page/mixin_page.dart';
import 'package:my_gallery/modules/flu_app/notification/notification_page.dart';
import 'package:my_gallery/modules/flu_app/personal/personal_page.dart';
import 'package:my_gallery/modules/flu_app/platform_view/platform_view_page.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/shop/meituan_shop_page.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/sliver_appbar_page.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/sliver_custom_header_page.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/sliver_entrance_page.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/sliver_list_page.dart';
import 'package:my_gallery/modules/flu_app/sliver_module/sliver_sticky_page.dart';
import 'package:my_gallery/modules/flu_app/splash_module/splash_page.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/list/LiveRoomCreate.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/list/LiveRoomList.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/room/LiveRoomPage.dart';
// import 'package:my_gallery/modules/flu_app/t_live/index.dart';
// import 'package:my_gallery/modules/flu_app/t_live/login/TLoginPage.dart';
import 'package:my_gallery/modules/flu_app/tabbar/tabbar_page.dart';

import '../canvas/paint_1_page.dart';
import '../canvas/paint_2_page.dart';
import '../canvas/paint_4_page.dart';
import 'flu_router_page_api.dart';

/// FluRouterDelegate继承自RouterDelegate，并混入ChangeNotifier和PopNavigatorRouterDelegateMixin
/// 有三个必须实现的方法
class FluRouterDelegate extends RouterDelegate<List<RouteSettings>> with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  /// 路由配置页面列表
  final List<Page> _pages = [];
  
  /// 必须实现的方法1 全局navigatorKey 保存全局context
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 必须实现的方法2 build方法 用于创建路由的管理者，主要有两个参数：pages和onPopPage；
  /// pages是存放Page对象的列表；Page是一种路由页面的描述或者路由页面的配置，用于生成真正的路由页面
  /// onPopPage当pop时，会被回调，这里可以拦截页面出栈处理
  /// Navigator2.0我们只要操作这个Page列表，相应的路由栈就会感知到，自动发生变化。我们想要哪个页面显示就把页面放到List的最上面就可以了。
  /// Navigator2.0把原来对形同和黑子的路由栈操作变成了一个对Page列表的操作。我们想改变路由栈页面的先后顺序，只需要修改List<Page>中元素的位置即可。
  /// Page类本身继承自RouteSettings类，说明它本身就是一个路由配置文件，它本身就是一个抽象类，不能实例化，可以用它的子类MaterialPage和CupertinoPage实例化。
  /// 写几个方法来操作Page列表
  /// 重写popRoute方法，用于操作页面返回，页面栈退出。当页面退到根路由页面的时候，可以弹出一个对话框询问用户是否要退出App
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onPopPage: _onPopPage,
      /// 监听某个页面
      observers: [kRouteObserver,kGlobalRouteObserver],
      //transitionDelegate: , 转场动画
    );
  }

  /// 重写popRoute方法，用于拦截页面返回操作
  ///
  /// @MethodName 页面返回拦截
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/9
  ///
  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    return _confirmExit();
  }

  /// 是否可以返回
  bool canPop() {
    return _pages.length > 1;
  }

  /// 页面返回拦截
  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (canPop()) {
      _pages.removeLast();
      return true;
    } else {
      return false;
    }
  }

  ///
  /// @MethodName 页面退出时，退出到最后一个页面弹出对话框询问用户是否退出
  /// @Parameter
  /// @ReturnType
  /// @Description
  /// @Author waitwalker
  /// @Date 2022/1/9
  ///
  Future<bool> _confirmExit() async {
    print(navigatorKey.currentState!.context);
    final result = await showDialog<bool>(context: navigatorKey.currentContext!, builder: (context){
      return AlertDialog(
        content: Text("确定要退出APP吗"),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context,true),
            child: Text("取消"),),
          TextButton(
            onPressed: ()=>Navigator.pop(context,false),
            child: Text("确定"),),
        ],
      );
    });
    return result ?? true;
  }

  /// 获取路由配置信息
  @override
  List<RouteSettings> get currentConfiguration => List.of(_pages);

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) {
    if (configuration.isNotEmpty) {
      print("新的路由路径：${configuration.last.name}");
      _setPath(configuration.map((routeSettings) => _createPage(routeSettings)).toList());
    }
    return Future.value(null);
  }

  _setPath(List<Page> pages) {
    _pages.clear();
    _pages.addAll(pages);
    if (_pages.first.name != '/') {

    }
    notifyListeners();
  }

  ///
  /// @MethodName 创建Pages
  /// @Parameter 
  /// @ReturnType 
  /// @Description 
  /// @Author waitwalker
  /// @Date 2022/1/8
  ///
  MaterialPage _createPage(RouteSettings routeSettings) {
    Widget childPage;
    switch (routeSettings.name){
      case FluRouterPageAPI.bottomNavigationBarPage:
        childPage = FluBottomNavigationBarPage();
        break;
      case FluRouterPageAPI.homePage:
        childPage = HomePage();
        break;
      case FluRouterPageAPI.isolatePage:
        childPage = IsolatePage();
        break;
      case FluRouterPageAPI.platformViewPage:
        childPage = PlatformViewPage();
        break;
      case FluRouterPageAPI.notificationPage:
        childPage = NotificationPage();
        break;
      case FluRouterPageAPI.mixinPage:
        childPage = MixinPage();
        break;
      case FluRouterPageAPI.animationPage:
        childPage = AnimationPage();
        break;
      case FluRouterPageAPI.heroPage:
        childPage = HeroPage(arguments: routeSettings.arguments as Map<String, String>,);
        break;
      case FluRouterPageAPI.eventPenetrationPage:
        childPage = EventPenetrationPage();
        break;
      case FluRouterPageAPI.positionAnimationPage:
        childPage = PositionAnimationPage();
        break;
      case FluRouterPageAPI.adPage:
        childPage = ADPage();
        break;
      case FluRouterPageAPI.adSplashPage:
        childPage = AdSplashPage();
        break;
      case FluRouterPageAPI.sliverEntrancePage:
        childPage = SliverEntrancePage();
        break;
      case FluRouterPageAPI.sliverListPage:
        childPage = SliverListPage();
        break;
      case FluRouterPageAPI.sliverAppBarPage:
        childPage = SliverAppBarPage();
        break;
      case FluRouterPageAPI.sliverStickyPage:
        childPage = SliverStickyPage();
        break;
      case FluRouterPageAPI.sliverCustomHeaderPage:
        childPage = SliverCustomHeaderPage();
        break;
      case FluRouterPageAPI.meituanShopPage:
        childPage = MeituanShopPage();
        break;
      case FluRouterPageAPI.tabBarPage:
        childPage = TabBarPage();
        break;
      case FluRouterPageAPI.keFramePage:
        childPage = KeFrameListViewPage();
        break;
      case FluRouterPageAPI.canvasPage:
        childPage = CanvasEntrancePage();
        break;
      case FluRouterPageAPI.paint1Page:
        childPage = Paint1Page();
        break;
      case FluRouterPageAPI.paint2Page:
        childPage = Paint2Page();
        break;
      case FluRouterPageAPI.paint3Page:
        childPage = Paint3Page();
        break;
      case FluRouterPageAPI.paint4Page:
        childPage = Paint4Page();
        break;
      case FluRouterPageAPI.paint5Page:
        childPage = Paint5Page();
        break;
      case FluRouterPageAPI.paint6Page:
        childPage = Paint6Page();
        break;
      case FluRouterPageAPI.paint7Page:
        childPage = Paint7Page();
        break;
      case FluRouterPageAPI.chartPage:
        childPage = ChartPage();
        break;
      case FluRouterPageAPI.splashPage:
        childPage = SplashPage();
        break;
      case FluRouterPageAPI.contactPage:
        childPage = ContactPage();
        break;
      case FluRouterPageAPI.chatPage:
        childPage = ChatPage(routeSettings.arguments as Map<String, String>);
        break;
      case FluRouterPageAPI.personalPage:
        childPage = PersonalPage();
        break;
      //  腾讯登录页面
      // case FluRouterPageAPI.tLoginPage:
      //   childPage = TLoginPage();
      //   break;
      // //  索引页面
      // case FluRouterPageAPI.indexPage:
      //   childPage = IndexPage();
      //   break;
      // //  直播列表页面
      // case FluRouterPageAPI.liveListPage:
      //   childPage = LiveRoomListPage();
      //   break;
      // //  创建直播页面
      // case FluRouterPageAPI.createLivePage:
      //   childPage = LiveRoomCreatePage();
      //   break;
      // //  主播页面 推流页面
      // case FluRouterPageAPI.livePage:
      //   childPage = LiveRoomPage(isAdmin: true);
      //   break;
      // //  观众页面 拉流页面
      // case FluRouterPageAPI.audiencePage:
      //   childPage = LiveRoomPage(isAdmin: false);
      //   break;

      default:
        /// 错误页面占位
        childPage = PlaceholderPage();
    }
    return MaterialPage(child: childPage,
      key: Key(routeSettings.name!) as LocalKey?,
      name: routeSettings.name,
      arguments: routeSettings.arguments
    );
  }
  
  ///
  /// @MethodName 压栈操作，push新页面
  /// @Parameter 
  /// @ReturnType 
  /// @Description 
  /// @Author waitwalker
  /// @Date 2022/1/8
  ///
  push({String? name, dynamic arguments}) {
    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
    print("当前pages列表：${_pages.length}, $_pages");
  }

  ///
  /// @MethodName 替换栈顶页面
  /// @Parameter 
  /// @ReturnType 
  /// @Description 
  /// @Author waitwalker
  /// @Date 2022/1/8
  ///
  replaceLastPage({String? name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(name: name, arguments: arguments);
  }

  replace({String? name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(name: name, arguments: arguments);
  }
  
}
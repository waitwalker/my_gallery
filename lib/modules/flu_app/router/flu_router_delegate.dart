import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/ad/ad_page.dart';
import 'package:my_gallery/modules/flu_app/ad/ad_splash_page.dart';
import 'package:my_gallery/modules/flu_app/chart/chart_page.dart';
import 'package:my_gallery/modules/flu_app/common/place_holder_page.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';
import 'package:my_gallery/modules/flu_app/entrance/flu_bottom_navigation_bar_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/animation/animation_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/animation/hero_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/animation/position_animation.dart';
import 'package:my_gallery/modules/flu_app/home_module/bottom_sheet_page/bottom_sheet_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/canvas_entrance_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_1_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_2_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_3_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_4_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_5_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_6_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/canvas/paint_7_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/event_penetration/event_penetration_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/isolate/isolate_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/ke_frame_listview/ke_frame_list_view_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/mixin_page/mixin_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/notification/notification_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/platform_view/platform_view_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/shop/complexity_scrollview_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/sliver_appbar_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/sliver_custom_header_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/sliver_entrance_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/sliver_list_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/sliver_module/sliver_sticky_page.dart';
import 'package:my_gallery/modules/flu_app/home_module/store/order/order_page.dart';
import 'package:my_gallery/modules/flu_app/message_module/chat_page.dart';
import 'package:my_gallery/modules/flu_app/message_module/contact_page.dart';
import 'package:my_gallery/modules/flu_app/personal/personal_page.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/modules/flu_app/splash_module/splash_page.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/list/LiveRoomCreate.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/list/LiveRoomList.dart';
// import 'package:my_gallery/modules/flu_app/t_live/TRTCLiveRoomDemo/ui/room/LiveRoomPage.dart';
// import 'package:my_gallery/modules/flu_app/t_live/index.dart';
// import 'package:my_gallery/modules/flu_app/t_live/login/TLoginPage.dart';
import 'package:my_gallery/modules/flu_app/tabbar/tabbar_page.dart';
import 'flu_router_page_api.dart';

/// NativeRouterDelegate，并混入ChangeNotifier和PopNavigatorRouterDelegateMixin， 这个delegate是flutter原生的不是第三方组件的
/// 有三个必须实现的方法
class NativeRouterDelegate extends RouterDelegate<List<RouteSettings>> with ChangeNotifier, PopNavigatorRouterDelegateMixin {

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
    kPrinter(navigatorKey.currentState!.context);
    final result = await showDialog<bool>(context: navigatorKey.currentContext!, builder: (context){
      return AlertDialog(
        content: const Text("确定要退出APP吗"),
        actions: [
          TextButton(
            onPressed: ()=>Navigator.pop(context,true),
            child: const Text("取消"),),
          TextButton(
            onPressed: ()=>Navigator.pop(context,false),
            child: const Text("确定"),),
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
      kPrinter("新的路由路径：${configuration.last.name}");
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
      case RouterPageAPI.bottomNavigationBarPage:
        childPage = const FluBottomNavigationBarPage();
        break;
      case RouterPageAPI.homePage:
        childPage = const HomePage();
        break;
      case RouterPageAPI.isolatePage:
        childPage = const IsolatePage();
        break;
      case RouterPageAPI.platformViewPage:
        childPage = PlatformViewPage();
        break;
      case RouterPageAPI.notificationPage:
        childPage = NotificationPage();
        break;
      case RouterPageAPI.mixinPage:
        childPage = MixinPage();
        break;
      case RouterPageAPI.animationPage:
        childPage = AnimationPage();
        break;
      case RouterPageAPI.heroPage:
        childPage = HeroPage(arguments: routeSettings.arguments as Map<String, String>,);
        break;
      case RouterPageAPI.eventPenetrationPage:
        childPage = const EventPenetrationPage();
        break;
      case RouterPageAPI.positionAnimationPage:
        childPage = PositionAnimationPage();
        break;
      case RouterPageAPI.adPage:
        childPage = ADPage();
        break;
      case RouterPageAPI.adSplashPage:
        childPage = AdSplashPage();
        break;
      case RouterPageAPI.sliverEntrancePage:
        childPage = SliverEntrancePage();
        break;
      case RouterPageAPI.sliverListPage:
        childPage = SliverListPage();
        break;
      case RouterPageAPI.sliverAppBarPage:
        childPage = SliverAppBarPage();
        break;
      case RouterPageAPI.sliverStickyPage:
        childPage = SliverStickyPage();
        break;
      case RouterPageAPI.sliverCustomHeaderPage:
        childPage = SliverCustomHeaderPage();
        break;
      case RouterPageAPI.meituanShopPage:
        childPage = const ComplexityScrollViewPage();
        break;
      case RouterPageAPI.tabBarPage:
        childPage = TabBarPage();
        break;
      case RouterPageAPI.bottomSheetPage:
        childPage = BottomSheetPage();
        break;
      case RouterPageAPI.orderPage:
        childPage = const OrderPage();
        break;
      case RouterPageAPI.keFramePage:
        childPage = KeFrameListViewPage();
        break;
      case RouterPageAPI.canvasPage:
        childPage = CanvasEntrancePage();
        break;
      case RouterPageAPI.paint1Page:
        childPage = Paint1Page();
        break;
      case RouterPageAPI.paint2Page:
        childPage = Paint2Page();
        break;
      case RouterPageAPI.paint3Page:
        childPage = Paint3Page();
        break;
      case RouterPageAPI.paint4Page:
        childPage = Paint4Page();
        break;
      case RouterPageAPI.paint5Page:
        childPage = Paint5Page();
        break;
      case RouterPageAPI.paint6Page:
        childPage = Paint6Page();
        break;
      case RouterPageAPI.paint7Page:
        childPage = Paint7Page();
        break;
      case RouterPageAPI.chartPage:
        childPage = ChartPage();
        break;
      case RouterPageAPI.splashPage:
        childPage = SplashPage();
        break;
      case RouterPageAPI.contactPage:
        childPage = ContactPage();
        break;
      case RouterPageAPI.chatPage:
        childPage = ChatPage(routeSettings.arguments as Map<String, String>);
        break;
      case RouterPageAPI.personalPage:
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
    kPrinter("当前pages列表：${_pages.length}, $_pages");
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
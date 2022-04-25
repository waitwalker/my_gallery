import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/common/deep_links/deep_links_manager.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';
import 'package:my_gallery/modules/flu_app/home_module/animation/position_animation_view_model.dart';
import 'package:my_gallery/modules/flu_app/home_module/home_change_notifier.dart';
import 'package:my_gallery/modules/flu_app/personal/personal_change_notifier.dart';
import 'package:my_gallery/modules/flu_app/router/flu_route_information_parser.dart';
import 'package:my_gallery/modules/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/modules/flu_app/router/navigator_view_model.dart';
import 'package:my_gallery/modules/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/modules/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';

class FluApp extends StatefulWidget {
  FluApp({Key? key}) : super(key: key){
    /// 初始化时添加第一个页面
    kRouterDelegate.push(name: RouterPageAPI.splashPage);
  }
  @override
  State<StatefulWidget> createState() {
    return _FluAppState();
  }
}

class _FluAppState extends State<FluApp> with WidgetsBindingObserver{


  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
  }


  @override
  void initState() {
    /// 监听方式1 全局监听
    kRouterDelegate.addListener(() {
      kPrinter("全局监听页面：${kRouterDelegate.currentConfiguration}");
      kPrinter("当前最上层页面：${kRouterDelegate.currentConfiguration.last.name}");
    });
    /// 如果组件还挂载在Widget树上
    if (mounted) {
      DeepLinksManager.handleInitialLink();
      DeepLinksManager.handleIncomingLinks();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => HomeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => PersonalChangeNotifier()),
        ChangeNotifierProvider(create: (context) => PositionAnimationViewModel()),
        ChangeNotifierProvider(create: (context) => NavigatorViewModel()),
      ],
      child: MaterialApp.router(
        routeInformationParser: FluRouteInformationParser(),
        routerDelegate: kRouterDelegate,
        // theme: ThemeData(
        //   primaryColor: themeColorList[Provider.of<ThemeChangeNotifier>(context).themeIndex],
        // ),
      ),
    );
  }

  @override
  void dispose() {
    DeepLinksManager.removeLinkStreamListener();
    super.dispose();
  }

}
import 'package:flutter/material.dart';
import 'package:my_gallery/flu_app/home_module/home_change_notifier.dart';
import 'package:my_gallery/flu_app/personal/personal_change_notifier.dart';
import 'package:my_gallery/flu_app/router/flu_route_information_parser.dart';
import 'package:my_gallery/flu_app/router/flu_router_page_api.dart';
import 'package:my_gallery/flu_app/router/router_delegate_manager.dart';
import 'package:my_gallery/flu_app/theme/theme_change_notifier.dart';
import 'package:provider/provider.dart';

class FluApp extends StatefulWidget {
  FluApp({Key? key}){
    /// 初始化时添加第一个页面
    kFluRouterDelegate.push(name: FluRouterPageAPI.splashPage);
  }
  @override
  State<StatefulWidget> createState() {
    return _FluAppState();
  }
}

class _FluAppState extends State<FluApp> with WidgetsBindingObserver{




  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
    super.didHaveMemoryPressure();
  }


  @override
  void initState() {
    /// 监听方式1 全局监听
    kFluRouterDelegate.addListener(() {
      print("全局监听页面：${kFluRouterDelegate.currentConfiguration}");
      print("当前最上层页面：${kFluRouterDelegate.currentConfiguration.last.name}");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => HomeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => PersonalChangeNotifier()),
      ],
      child: MaterialApp.router(
        routeInformationParser: FluRouteInformationParser(),
        routerDelegate: kFluRouterDelegate,
        // theme: ThemeData(
        //   primaryColor: themeColorList[Provider.of<ThemeChangeNotifier>(context).themeIndex],
        // ),
      ),
    );
  }

}
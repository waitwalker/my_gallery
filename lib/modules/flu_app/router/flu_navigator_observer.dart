import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/printer.dart';

///
/// @ClassName 全局监听路由页面变化
/// @Description 
/// @Author waitwalker
/// @Date 2022/1/11
///
class FluNavigatorObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  @override
  void didPush(Route route, Route? previousRoute) {
    printer("didPush ${route.settings.name}");
    if ((previousRoute is TransitionRoute) && previousRoute.opaque) {
      //全屏不透明，通常是一个page
    } else {
      //全屏透明，通常是一个弹窗
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    printer("didPop${route.settings.name}");
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    printer("didRemove${route.settings.name}");
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    printer("didReplace${newRoute!.settings.name}");
    super.didReplace(newRoute:newRoute, oldRoute:oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    printer("didStartUserGesture${route.settings.name}");
    super.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    printer("didStopUserGesture");
    super.didStopUserGesture();
  }
}

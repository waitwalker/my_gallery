import 'package:my_gallery/common/const/router_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// @description 路由管理
/// @author waitwalker
/// @time 3/18/21 9:41 AM
///
class NavigatorRoute {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///启动动画
  static launch(BuildContext context) {
    Navigator.pushReplacementNamed(context, RouteConst.launch);
  }

  ///主页
  static goToTabBarPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, RouteConst.tab_bar_home);
  }

  ///主页
  static backHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, RouteConst.tab_bar_home, (Route<dynamic> route) => false);
  }

  ///
  /// @name login
  /// @description 跳转到登录页
  /// @parameters
  /// @return
  /// @author waitwalker
  /// @date 2020-01-10
  ///
  static login(BuildContext context) {
    // param3: To remove route before login
    Navigator.pushReplacementNamed(context, RouteConst.login);
  }
}

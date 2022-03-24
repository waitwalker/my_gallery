import 'package:flutter/material.dart';

/// 2创建服务
class NavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? get navigator => navigatorKey.currentState;
  get pushNamed => navigator!.pushNamed;
  get push => navigator!.push;
}
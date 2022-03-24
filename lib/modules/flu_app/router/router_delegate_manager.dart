import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/router/flu_navigator_observer.dart';
import 'flu_router_delegate.dart';

FluRouterDelegate kFluRouterDelegate = FluRouterDelegate();

RouteObserver<PageRoute> kRouteObserver = RouteObserver<PageRoute>();

RouteObserver<PageRoute> kGlobalRouteObserver = FluNavigatorObserver<PageRoute>();

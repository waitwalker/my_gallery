
import 'package:my_gallery/modules/flu_app/entrance/flu_bottom_navigation_bar_page.dart';

/// @fileName singleton_manager.dart
/// @description 单例类 提供一些全局变量&方法访问
/// @date 2022/3/23 10:39 上午
/// @author LiuChuanan
class SingletonManager {

  late FluBottomNavigationBarPageState fluBottomNavigationBarPageState;
  SingletonManager._privateConstructor();
  static final SingletonManager _instance = SingletonManager._privateConstructor();
  static SingletonManager get sharedInstance => _instance;

  /// methodName debugToast
  /// description Debug toast 弹窗调试
  /// date 2022/4/11 10:29
  /// author LiuChuanan
  debugToast({String? message}) {

  }

}
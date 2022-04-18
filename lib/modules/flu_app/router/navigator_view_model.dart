
import 'package:flutter/foundation.dart';
import 'package:my_gallery/modules/flu_app/common/singleton_manager.dart';

class NavigatorViewModel extends ChangeNotifier {
  late int _homeTabCount = 1;
  get homeTabCount => _homeTabCount;

  void setHomeTabCount(int value) {
    _homeTabCount = value;
    notifyListeners();
    SingletonManager.sharedInstance.fluBottomNavigationBarPageState.setIndex(0);
  }
}
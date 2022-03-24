import 'package:flutter/material.dart';

class ThemeChangeNotifier extends ChangeNotifier {
  int _themeIndex = 0;
  setTheme(int index) {
    _themeIndex = index;
    notifyListeners();
  }

  get themeIndex => _themeIndex;
}

/// 主题颜色
final List<Color> themeColorList = [
  Colors.blue,
  Colors.red,
  Colors.purple,
  Colors.indigo,
  Colors.yellow,
  Colors.green,
];

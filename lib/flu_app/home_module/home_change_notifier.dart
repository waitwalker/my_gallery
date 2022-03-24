import 'package:flutter/material.dart';

class HomeChangeNotifier extends ChangeNotifier {
  bool _loading = true;
  bool _hasError = false;
  loadHomeData(int loadState) {
    if (loadState > 0) {
      _loading = true;
      _hasError = false;
      notifyListeners();
      Future.delayed(Duration(seconds: 2),(){
        _loading = false;
        _hasError = false;
        notifyListeners();
      });
    } else {
      Future.delayed(Duration(seconds: 2),(){
        _loading = false;
        _hasError = false;
        notifyListeners();
      });
    }
  }

  /// 是否正在加载
  get loading => _loading;

  /// 是否有错误
  get hasError => _hasError;
}
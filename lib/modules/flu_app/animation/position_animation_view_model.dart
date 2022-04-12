import 'package:flutter/material.dart';

class PositionAnimationViewModel extends ChangeNotifier {

  late bool _show = true;
  get show => _show;

  void setShow(bool value) {
    _show = value;
    notifyListeners();
  }
}
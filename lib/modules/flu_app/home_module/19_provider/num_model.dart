import 'package:flutter/material.dart';

class NumModel extends ChangeNotifier {
  int _num = -1;
  get num=>_num;


  int _age = -1;
  get age=>_age;

  int _height = -1;
  get height=>_height;

  void setNum(int value) {
    _num = value;
    notifyListeners();
  }


  void setAge(int value) {
    _age = value;
    notifyListeners();
  }

  void setHeight(int value) {
    _height = value;
    notifyListeners();
  }
}
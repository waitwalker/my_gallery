import 'package:flutter/cupertino.dart';

class PersonalChangeNotifier extends ChangeNotifier {

  int _count = 0;

  get count=>_count;

  increaseCount() {
    _count++;
    notifyListeners();
  }
}
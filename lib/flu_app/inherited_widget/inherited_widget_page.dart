import 'package:flutter/material.dart';

class InheritedWidgetPage extends InheritedWidget {
  const InheritedWidgetPage({ Key? key, required Widget child })
      : super(key: key, child: child);
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  @override
  InheritedElement createElement() {
    return InheritedElementPage(this);
  }

}

class InheritedElementPage extends InheritedElement {
  InheritedElementPage(InheritedWidget widget) : super(widget);

  String value = "InheritedElement中的value";
}
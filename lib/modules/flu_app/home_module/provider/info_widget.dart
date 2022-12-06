import 'package:flutter/material.dart';

/// 要共享数据的InheritedWidget
class InfoWidget extends InheritedWidget {

  /// 要共享的数据
  final int num;

  /// child 是子Widget
  const InfoWidget({
    Key? key,
    required this.num,
    required Widget child,})
      : super(key: key,child: child);

  /// 子类重写updateShouldNotify，这个方法如果返回true，则会回调子Widget StatefulElement中的state didChangeDependencies方法
  @override
  bool updateShouldNotify(covariant InfoWidget oldWidget) {
    return num != oldWidget.num;
  }

  /// of这个静态方法是留给子孙Widget使用的，子孙Widget可以通过它获取到InheritedWidget的共享数据
  /// 取of方法名是个约定俗成，也可以随便取其他方法名
  static InfoWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

}


/// 创建一个Widget，用于显示InfoWidget共享的数据

class InfoChildWidget extends StatelessWidget {

  /// 使用常量构造函数是为了解决不必要的重建和销毁
  const InfoChildWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int num = InfoWidget.of(context)?.num ?? -1;
    return Text("#$num",style: TextStyle(color: Colors.amber, fontSize: 35),);
  }

}
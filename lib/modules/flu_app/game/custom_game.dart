import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';

class CustomGame extends FlameGame {

  /// 在游戏里面绘制一个圆，并让这个圆每一帧在x和y上移动1个像素
  Offset circleCenter = const Offset(0, 0);
  final Paint paint = Paint()..color = Colors.yellow;

  /// methodName render
  /// description render方法用于渲染，有一个参数canvas，我们可以在render方法里通过canvas绘制我们想要的游戏内容
  /// date 2022/4/24 16:28
  /// author LiuChuanan
  @override
  void render(Canvas canvas){
    super.render(canvas);
    kPrinter("CustomGame printer");
    canvas.drawCircle(circleCenter, 20, paint);
  }

  /// methodName update
  /// description 用于游戏更新 dt参数表示时间间隔，单位是秒，即间隔多久调用一次update和render方法
  /// date 2022/4/24 16:27
  /// author LiuChuanan
  @override
  void update(double dt) {
    super.update(dt);
    kPrinter("CustomGame update");
    circleCenter = circleCenter.translate(1, 1);
  }


}
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:my_gallery/modules/flu_app/config/k_printer.dart';

/// @fileName custom_game.dart
/// @description 游戏Flame
/// @date 2022/4/24 16:42
/// @author LiuChuanan
/// FlameGame 生命周期方法
/// 游戏初次添加到 Flutter 的 Widget 树时会回调 onGameResize, 然后依次回调 onLoad、onMount ，之后将循环调用 update 和 render 方法，当游戏从 Flutter 的 Widget 树中移除时调用 onRemove 方法。
/// 当游戏画布大小发生改变时会回调 onGameResize 方法，可以再该方法里重新初始化游戏里相关元素的大小和位置。
/// onLoad 在整个 FlameGame 的生命周期里只会调用一次，而其他生命周期方法都可能会多次调用，所以我们可以在 onLoad 中进行游戏的一些初始化工作。
class CustomGame extends FlameGame {

  /// 在游戏里面绘制一个圆，并让这个圆每一帧在x和y上移动1个像素
  Offset circleCenter = const Offset(0, 0);
  final Paint paint = Paint()..color = Colors.yellow;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    kPrinter("1游戏初次添加到Flutter的Widget树时会回调onGameResize方法");
  }

  @override
  Future<void>? onLoad() {
    kPrinter("2然后依次调用onLoad方法，onLoad方法在整个FlameGame的生命周期里只会调用一次，而其他的生命周期方法可能会多次调用，所以可以在onLoad方法进行游戏的一些初始化工作");
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    kPrinter("3然后依次调用onMount方法");
  }


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

  @override
  void onRemove() {
    super.onRemove();
    kPrinter("当游戏从Flutter的Widget树中移除时调用onRemove");
  }


}